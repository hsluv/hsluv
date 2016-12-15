// CommonJS module system (including Node)
if (typeof module !== 'undefined') {
    module['exports'] = husl;
}

// AMD module system
if (typeof define !== 'undefined') {
    define(husl);
}

// Export to browser
if (typeof window !== 'undefined') {
    window['HUSL'] = husl;
}
