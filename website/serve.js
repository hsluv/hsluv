import * as fs from 'fs/promises';
import * as http from 'http';

const port = 8080;
const server = http.createServer(async (req, res) => {
    try {
        console.log(req.url);
        let f = 'dist' + req.url;
        const stat = await fs.stat(f);
        if (stat.isDirectory()) {
            f += 'index.html'
        }
        const data = await fs.readFile(f);
        res.writeHead(200);
        res.end(data);
    } catch (e) {
        res.writeHead(404);
        res.end(e.message);
    }
});
server.listen(port, () => console.log(`listening on http://localhost:${port}`));
