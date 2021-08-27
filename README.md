# DU-screen-linesbox
Writes lines of text and images into a text area in a screen element in Dual Universe (game)

## Usage

**1) Edit the content table,** which is a table - where each row of text and/or an image
   is itself represented by a table, including the following for **each row:**


All elements are optional:

*  .message = one line of text of one style
*  .imgPath = relative path URL to a NQ approved image or local resource
*  .align = text alignment, either "left", "right or "center" (default)
*  .colorRgba = text colour RGB in [0..255] eg. {255,255,255,1.0} is white
*  .style = name of style
*  .lineHeight = relative vertical distance from line above, or image height in lines;
     a "line" is defined by lineHeightDefault so can be in pixels, as pitch is
     adjusted accordingly; text is middle aligned vertically within the line.
*  .imgPosX, .imgPosY (both or none) = absolute top left pos of image relative to text box;
     image is centred and positioned just below the line above if no pos given.
*  .imgWidth, .imgHeight (both or none) = size (for aspect ratio if no pos);
     aspect ratio defaults to 1.0 if either height or width are missing;

  Images scale to fit .lineHeight if no pos given, keeping aspect ratio, and
  any text will write on top, middle aligned on the image. NQ recommends
  not relying on this order, so later versions of this will separate the image layer.
  It is possible to specify a negative .lineHeight with empty text, to create
  interesting effects such as a tall image behind multiple lines of text.

**2) Optionally edit the styles.** The following elements are optional, but
one fully-specified style must be identified by defaultStyleName. Where an attribute is not defined, the
default value is used.

* .fontName, .fontSize
* .font (use loadFont() to define .font, and reuse loaded fonts where possible*)
* .colorRgba = text color
* .align = text alignment, either 'left', 'right' or 'center' (default)

Examples are given that might be used for simple signage.

N.B. do not exceed the screen API limit of 8 font name/size combos.

**3) Optionally edit the call to writeTextArea(),** to specify the text area background
   box dimensions/location and content to use.

* layer = text layer id (mandatory)
* imgLayer = image layer id (mandatory, can be same as layer)
* contentLines = table of content (mandatory, see 1 above)
* styles = table of styles (mandatory, see 2 above)
* xPos, yPos = top left corner position on screen
* width, height = box width & height
* paddingX, paddingY = padding inside the box; user must size text to fit width
* boxLayer, boxBackgroundRgba = box layer and colour

# To Do

1. Text alignment like it says above
2. Error handling
