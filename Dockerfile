FROM node:18-slim AS base
ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PATH"
RUN corepack enable
COPY . /app
WORKDIR /app

ENV NEXT_TELEMETRY_DISABLED 1
ENV NODE_ENV production

FROM base AS prod-deps
RUN --mount=type=cache,id=pnpm,target=/pnpm/store pnpm install --prod --frozen-lockfile

FROM base AS build
RUN --mount=type=cache,id=pnpm,target=/pnpm/store pnpm install --frozen-lockfile
RUN pnpm run -r build

FROM base AS adder
COPY --from=prod-deps /app/packages/adder/node_modules/ /app/packages/addder/node_modules
COPY --from=build /app/packages/adder/dist /app/packages/adder/dist


FROM adder AS frontend
COPY --from=prod-deps /app/apps/frontend/node_modules/ /app/apps/frontend/node_modules
COPY --from=build /app/apps/frontend/.next/standalone/apps/frontend /app/apps/frontend/
COPY --from=build /app/apps/frontend/.next/static /app/apps/frontend/.next/static
WORKDIR /app/apps/frontend
EXPOSE 8000
CMD [ "pnpm", "start" ]


FROM adder AS server
COPY --from=prod-deps /app/apps/server/node_modules/ /app/apps/server/node_modules
COPY --from=build /app/apps/server/dist /app/apps/server/
WORKDIR /app/apps/server
EXPOSE 8000
CMD [ "pnpm", "start" ]
