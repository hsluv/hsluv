// CommonJS module system (including Node)
if (typeof module !== 'undefined') {
    module['exports'] = root;
}

// AMD module system
if (typeof define !== 'undefined') {
    define(root);
}

// Export to browser
if (typeof window !== 'undefined') {
    window['hsluv'] = root;
}
