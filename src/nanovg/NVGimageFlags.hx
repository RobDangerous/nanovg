package nanovg;

enum abstract NVGimageFlags(Int) from Int to Int {
    var NVG_IMAGE_GENERATE_MIPMAPS	= 1<<0;     // Generate mipmaps during creation of the image.
	var NVG_IMAGE_REPEATX			= 1<<1;		// Repeat image in X direction.
	var NVG_IMAGE_REPEATY			= 1<<2;		// Repeat image in Y direction.
	var NVG_IMAGE_FLIPY				= 1<<3;		// Flips (inverses) image in Y direction when rendered.
	var NVG_IMAGE_PREMULTIPLIED		= 1<<4;		// Image data has premultiplied alpha.
	var NVG_IMAGE_NEAREST			= 1<<5;		// Image interpolation is Nearest instead Linear
}
