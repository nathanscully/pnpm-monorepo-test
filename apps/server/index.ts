import add from "adder";
import fastify, {
  FastifyInstance,
  type FastifyRequest,
  FastifyReply,
} from "fastify";

const server = fastify();

server.get("/ping", async (request: FastifyRequest, reply) => {
  return "pong\n";
});

server.get("/adder", async (request: any, reply: any) => {
  const { a, b } = request.query;
  return add(Number.parseInt(a), Number.parseInt(b));
});

server.listen({ port: 8080, host: "::" }, (err, address) => {
  if (err) {
    console.error(err);
    process.exit(1);
  }
  console.log(`Server listening at ${address}`);
});
