const fs = require('fs');
const hsluv = require('hsluv');
const mustache = require('mustache');


const pages = [
    {
        page: 'index',
        index: true,
        bodyClass: 'dark',
        title: 'HSLuv'
    },
    {
        page: 'comparison',
        title: 'Comparing HSLuv to HSL'
    },
    {
        page: 'implementations',
        title: 'Implementations'
    },
    {
        page: 'math',
        title: 'Math'
    },
    {
        page: 'examples',
        title: 'Usage examples'
    },
    {
        page: 'credits',
        title: 'Credits'
    }
];

function demoColorBars() {
    let numBars = 15;
    let lightness = 60;
    let saturation = 90;
    let hslColors = [];
    let hsluvColors = [];
    for (let i = 0; i < numBars; i++) {
        let hue = 360 * i / numBars;
        let hslColor = `hsl(${hue}, ${saturation}%, ${lightness}%)`;
        let hsluvColor = hsluv.Hsluv.hsluvToHex([hue, saturation, lightness]);
        hslColors.push(hslColor);
        hsluvColors.push(hsluvColor);
    }
    return {
        hslColors: hslColors,
        hsluvColors: hsluvColors
    }
}

function makeDir(path) {
    if (!fs.existsSync(path)) {
        console.log('creating directory', path);
        fs.mkdirSync(path);
    }
}

function generateHtml(targetDir) {
    const baseTemplate = fs.readFileSync(__dirname + '/templates/base.mustache').toString();
    const pageTemplateContext = {
        demoColorBars: demoColorBars()
    };

    for (let pageInfo of pages) {
        let pageTemplate = fs.readFileSync(__dirname + '/content/' + pageInfo.page + '.mustache').toString();
        let pageContent = mustache.render(pageTemplate, pageTemplateContext);
        let baseTemplateContext = {
            content: pageContent,
            bodyClass: pageInfo.bodyClass,
            title: pageInfo.title
        };
        let target;
        if (pageInfo.index) {
            target = targetDir + '/' + pageInfo.page + '.html';
        } else {
            makeDir(targetDir + '/' + pageInfo.page);
            target = targetDir + '/' + pageInfo.page + '/index.html';
        }
        console.log('generating ' + target);
        let renderedContent = mustache.render(baseTemplate, baseTemplateContext);
        fs.writeFileSync(target, renderedContent);
    }
}

if (require.main === module) {
    generateHtml(process.argv[2]);
}
