var fs = require('fs');
var mustache = require('mustache');


function makeDir(path) {
    if (!fs.existsSync(path)) {
        console.log('creating directory', path);
        fs.mkdirSync(path);
    }
}

function generateHtml(targetDir) {
    var baseTemplate = fs.readFileSync(__dirname + '/templates/base.mustache').toString();
    var pages = [
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
            page: 'syntax',
            title: 'Random Syntax Highlighting Color Schemes',
            bodyClass: 'dark'
        },
        {
            page: 'credits',
            title: 'Credits'
        }
    ];

    pages.forEach(function (pageInfo) {
        var pageContent = fs.readFileSync(__dirname + '/content/' + pageInfo.page + '.html').toString();
        var target;
        var context = {
            content: pageContent,
            bodyClass: pageInfo.bodyClass,
            title: pageInfo.title
        };
        if (pageInfo.index) {
            target = targetDir + '/' + pageInfo.page + '.html';
        } else {
            makeDir(targetDir + '/' + pageInfo.page);
            target = targetDir + '/' + pageInfo.page + '/index.html';
        }
        console.log('generating ' + target);
        var renderedContent = mustache.render(baseTemplate, context);
        fs.writeFileSync(target, renderedContent);
    });
}

if (require.main === module) {
    var targetDir = process.argv[2];
    generateHtml(targetDir);
}
