import * as fs from 'fs/promises';
import * as path from 'path';

const distDir = process.argv[2] || 'dist';

async function walk(dir) {
    const entries = await fs.readdir(dir, { withFileTypes: true });
    const files = [];
    for (const entry of entries) {
        const full = path.join(dir, entry.name);
        if (entry.isDirectory()) {
            files.push(...await walk(full));
        } else if (entry.name.endsWith('.html')) {
            files.push(full);
        }
    }
    return files;
}

// Resolve an internal URL to the file the server would return for it.
function resolveTarget(url) {
    const clean = url.split('#')[0].split('?')[0];
    if (!clean.startsWith('/')) return null;
    const rel = clean.slice(1);
    const candidates = rel === '' || rel.endsWith('/')
        ? [path.join(rel, 'index.html')]
        : [rel, path.join(rel, 'index.html')];
    return candidates;
}

async function exists(p) {
    try {
        const stat = await fs.stat(path.join(distDir, p));
        return stat.isFile();
    } catch {
        return false;
    }
}

const htmlFiles = await walk(distDir);
const problems = [];
let checked = 0;

for (const file of htmlFiles) {
    const html = await fs.readFile(file, 'utf8');
    const page = '/' + path.relative(distDir, file);

    for (const match of html.matchAll(/(?:href|src)="([^"]*)"/g)) {
        const url = match[1];
        const candidates = resolveTarget(url);
        if (candidates === null) continue;
        checked++;
        let found = false;
        for (const candidate of candidates) {
            if (await exists(candidate)) {
                found = true;
                break;
            }
        }
        if (!found) {
            problems.push(`${page}: ${url}`);
        }
    }
}

if (problems.length > 0) {
    console.error(`Broken internal links (${problems.length}):`);
    for (const problem of problems) console.error('  ' + problem);
    process.exit(1);
}

console.log(`OK: ${checked} internal links across ${htmlFiles.length} pages.`);
