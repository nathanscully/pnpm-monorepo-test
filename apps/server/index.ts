import fastify, { FastifyInstance, FastifyRequest, FastifyReply } from 'fastify';
import add from 'adder';

const server = fastify()

server.get('/ping', async (request: FastifyRequest, reply) => {
    return 'pong\n'
})

server.get('/adder', async (request:any, reply:any) => {
    const { a, b } = request.query;
    return add(parseInt(a),parseInt(b));
});


server.listen({ port: 8080, host: '::'}, (err, address) => {
    if (err) {
        console.error(err)
        process.exit(1)
    }
    console.log(`Server listening at ${address}`)
})
