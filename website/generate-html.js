import * as fs from 'fs';
import mustache from "mustache";
import {Hsluv} from "hsluv";

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
    const numBars = 15;
    const lightness = 60;
    const saturation = 90;
    const hslColors = [];
    const hsluvColors = [];
    const conv = new Hsluv();
    for (let i = 0; i < numBars; i++) {
        let hue = 360 * i / numBars;
        let hslColor = `hsl(${hue}, ${saturation}%, ${lightness}%)`;
        conv.hsluv_h = hue;
        conv.hsluv_s = saturation;
        conv.hsluv_l = lightness;
        conv.hsluvToHex();
        hslColors.push(hslColor);
        hsluvColors.push(conv.hex);
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
    const baseTemplate = fs.readFileSync('./website/templates/base.mustache').toString();
    const pageTemplateContext = {
        demoColorBars: demoColorBars()
    };

    for (let pageInfo of pages) {
        let pageTemplate = fs.readFileSync('./website/content/' + pageInfo.page + '.mustache').toString();
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

generateHtml(process.argv[2]);
