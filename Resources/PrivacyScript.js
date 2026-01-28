// Privacy: Fingerprinting Protection
// Override Canvas API
const getContext = HTMLCanvasElement.prototype.getContext;
HTMLCanvasElement.prototype.getContext = function(type) {
    if (type === '2d') {
        // We could return a fuzzed context here, or just let it be but warn.
        // For strict privacy, we can simply block it or fuzz readback.
        // Here we stub toDataURL to return nothing to prevent extraction.
    }
    return getContext.apply(this, arguments);
};

const toDataURL = HTMLCanvasElement.prototype.toDataURL;
HTMLCanvasElement.prototype.toDataURL = function() {
    // Return empty or random noise
    return "data:image/png;base64,"; 
};
