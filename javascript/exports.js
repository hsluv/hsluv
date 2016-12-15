// CommonJS module system (including Node)
if (typeof module !== 'undefined') {
    module['exports'] = hsluv;
}

// AMD module system
if (typeof define !== 'undefined') {
    define(hsluv);
}

// Export to browser
if (typeof window !== 'undefined') {
    window['hsluv'] = hsluv;
}
