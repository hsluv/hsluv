// TODO: Deprecated. Remove with the next major version
// Export to jQuery
if (typeof jQuery !== 'undefined') {
    jQuery['husl'] = exportObject;
}

// CommonJS module system (including Node)
if (typeof module !== 'undefined') {
    module['exports'] = exportObject;
}

// AMD module system
if (typeof define !== 'undefined') {
    define(exportObject);
}

// Export to browser
if (typeof window !== 'undefined') {
    window['HUSL'] = exportObject;
}