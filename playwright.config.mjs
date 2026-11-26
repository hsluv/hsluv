import { defineConfig } from '@playwright/test';

export default defineConfig({
    testDir: './website/test',
    testMatch: '*.spec.mjs',
    // Serve the built site so the tests exercise what is actually deployed.
    webServer: {
        command: 'node website/serve.js',
        port: 8080,
        reuseExistingServer: !process.env.CI,
    },
    use: {
        baseURL: 'http://localhost:8080',
    },
    projects: [
        { name: 'desktop', use: { viewport: { width: 1200, height: 900 } } },
        { name: 'mobile', use: { viewport: { width: 390, height: 844 }, isMobile: true, hasTouch: true } },
    ],
});
