-- # DU-screen-linesbox
-- Source and usage: https://github.com/kronius12/DU-screen-linesbox
-- License: GNU Public License 3.0
-- Version 1.1.0
--
-- This example creates columns of text and images inside boxes with margins.
-- You specify header (displayed in a box), content (multiple boxes across)
-- and footer (no box). Once you settle on styles and content, it does the rest.
-- Note the use of lineHeight to vary the size of the images.
--
-- Donations in-game to Kronius welcome but not required.

-- ***** 1) EDIT CONTENT HERE *****
-- pick from the styles defined in (2) below
-- example tables of messages and their styles are given

local header={
    {message="DU-screen-linesbox", style="heading" },
    {message="multi-column-example.lua", style="heading" },
    }
header.boxBackgroundColor = {48,48,48, 1.0}
header.boxRadiusLines = 2

local columns={}
local imgHeight = 2.5
local imgPath = "resources_generated/elements/engines/engine-atmospheric-vertical-booster_001_m/icons/env_engine-atmospheric-vertical-booster_001_m_icon.png"

table.insert(columns, {
    {message="Some text", style="elementHeading", lineHeight = 1 },
    {lineHeight = 0.4 },
    {imgPath=imgPath, lineHeight = imgHeight-0.8},
    {lineHeight = 0.4 },
    {message="More text", style="element", lineHeight = 1 },
    })

imgHeight = 2.2
imgOffsetY = 0.7
table.insert(columns, {
    {lineHeight=imgOffsetY},
    {imgPath=imgPath, lineHeight=imgHeight, align="left"},
    {lineHeight=-imgHeight},
    {imgPath=imgPath, lineHeight=imgHeight, align="right"},
    {lineHeight=-imgHeight-imgOffsetY},
        
    {message="Example", style="elementHeading", lineHeight = 1 },
    {lineHeight = 0.2 },
    {message="STYLED TEXT", style="red"},
    {lineHeight = 0.2 },
    {message="over an image", style="element", lineHeight = 1 },
    })
columns[#columns].boxBackgroundColor = {0,48,20, 0.8}
columns[#columns].boxRadius = 40

table.insert(columns, {
    {message="?", style="elementHeading", lineHeight = 1 },
    {imgPath="resources_generated/iconsLib/elementslib/coreunitstatic256.png", lineHeight = imgHeight},
    {message="1,000ħ", style="element", lineHeight = 1 },
    })
columns[#columns].boxRadiusLines = 4

local footer = {
{message="Source and usage: ", style="details"},
{message="https://github.com/kronius12", style="details"},
{message="/DU-screen-linesbox", style="details"},
}

-- ***** 2) EDIT STYLE DEFS HERE *****

-- default parameters - you need these
backgroundColor = {70,70,18}  -- screen background
boxBackgroundDefault = {0,48,120, 1} -- box colour
defaultFontSize = 40          -- reduce this to fit more text
defaultLineHeight = 1.0       -- a standard line is 1 line high,
    -- or change to defaultFontSize if you'd rather work in pixels
defaultPadding = 20           -- whitespace inside box
defaultBoxRadius = 10
defaultAspectRatio = 1.0      -- 1.0 for in-game icons; 1920/1080 for 16:9 landscape 
defaultTextAlign = "center"   -- text and images

local function getStyles()
    -- you could craft multiple functions to create various style sets
    -- you can edit, see documentation for available parameters

    local styles={}

    -- default must be fully specified
    styles.default={ 
        fontName="RobotoCondensed", 
        fontSize=defaultFontSize, 
        lineHeight=defaultLineHeight,
        align=defaultTextAlign,
        colorRgba={255,255,255,1.0},
        }
    styles.default.font = loadFont(styles.default.fontName, styles.default.fontSize)

    -- other styles as wanted
    styles.heading={
        fontName="Play-Bold", 
        fontSize=defaultFontSize * 1.5, 
        lineHeight=defaultLineHeight * 1.4, 
        colorRgba={196,196,255,1.0}}
    styles.heading.font = loadFont(styles.heading.fontName, styles.heading.fontSize)

    styles.element={colorRgba={16,255,255,1.0}}

    styles.elementHeading={font=styles.heading.font, 
        fontSize = styles.heading.fontSize, 
        lineHeight=styles.heading.lineHeight, 
        colorRgba=styles.element.colorRgba}
    styles.details={
        fontName="Montserrat-Light", 
        fontSize=styles.default.fontSize * 0.8, 
        lineHeight=defaultLineHeight*0.8, 
        colorRgba={240,255,240,1.0}}
    styles.details.font = loadFont(styles.details.fontName, styles.details.fontSize)
    styles.red={colorRgba={220,0,0,1.0}, font=styles.details.font}

    return styles
end

-- ***** 3) EDIT HERE WHAT IT DOES *****
-- This example takes tables of messages as header and footer, and
-- a table of tables containing messages to go in columns in the middle.

local function main()
    local margin = 20
    local padding = defaultPadding
    
    local rx, ry = getResolution()   -- Gets the resolution of the screen
    local boxLayer = createLayer()   -- Creates a new layer, index 1
    local imgLayer = createLayer()   -- Creates a layer on top of boxLayer
    local textLayer = createLayer()  -- Creates a layer on top of boxLayer and imgLayer
    local styles = getStyles()       -- Table of styles for this text
    setBackgroundColor(normaliseRgb(backgroundColor))
    
    -- *** EDIT THIS ***
    -- This works out the position of each text box as it goes
    
    -- Total height of text
    local nHeadingLines = getLineCount(header, styles)
    local nColLines = getLineCount(columns[1], styles) -- assume they're the same
    local nFooterLines = getLineCount(footer, styles)
    local totalLines = nHeadingLines + nColLines + nFooterLines
    
    -- Total white space top, between boxes, and bottom
    local totalMargins = margin * 2
    if nHeadingLines > 0 then totalMargins = totalMargins + margin end -- after header
    if nColLines > 0 then totalMargins = totalMargins + margin end -- after text

    local totalPadding = 0
    if nHeadingLines > 0 then totalPadding = totalPadding + padding * 2 end -- header
    if nColLines > 0 then totalPadding = totalPadding + padding * 2 end -- text
    -- if nFooterLines > 0 then totalPadding = totalPadding + padding * 2 end -- footer no padding

    -- Total pitch
    local textPitch = (ry - totalMargins - totalPadding) / totalLines    
    local nextBoxTop=margin
    local boxHeight=0

    -- write header in a box
    if nHeadingLines > 0 then
        boxHeight=nHeadingLines*textPitch + padding*2
        local boxBackground = (header.boxBackgroundColor or (boxBackgroundDefault or backgroundColor))
        local boxRadius = header.boxRadius or ((header.boxRadiusLines or 0) * defaultFontSize)

        writeTextArea(textLayer, imgLayer, header, styles, 
            margin, nextBoxTop, 
            rx - 2*margin, boxHeight,
            padding, padding, 
            boxLayer, boxBackground, boxRadius)
        nextBoxTop = nextBoxTop + boxHeight + margin
    end

    -- write columns in boxes
    if nColLines > 0 then
        boxHeight = nColLines*textPitch + padding*2
        for i, content in ipairs(columns) do
            local offset = rx*(i-1)/#columns + margin/2
            local boxWidth = rx/#columns - margin
            if i == 1 then 
                offset = margin 
                boxWidth = boxWidth - margin*0.5
            end
            if i == #columns then
                boxWidth = boxWidth - margin*0.5
            end
            local boxBackground = (content.boxBackgroundColor or (boxBackgroundDefault or backgroundColor))

            writeTextArea(textLayer, imgLayer, content, styles,
                offset, nextBoxTop,
                boxWidth, boxHeight,
                padding, padding, 
                boxLayer) -- box bkg & radius optional example
        end
        nextBoxTop = nextBoxTop + boxHeight + margin
    end
    
    -- write footer - no box drawn but does apply padding
    if nFooterLines > 0 then
        boxHeight = nFooterLines*textPitch
        writeTextArea(textLayer, imgLayer, footer, styles,
            0, nextBoxTop,
            rx, boxHeight,
            padding, 0)
        nextBoxTop = nextBoxTop + boxHeight + margin
    end
end
-- *** END OF USER EDITABLE SECTION ***

-- ***** WORKINGS *****
defaultStyleName = "default" -- option to set a different default

-- function defs
function normaliseRgb(rgb)   return rgb[1]/255, rgb[2]/255, rgb[3]/255 end
function normaliseRgba(rgba) return rgba[1]/255,rgba[2]/255,rgba[3]/255, rgba[4] end

function getLineCount(content, styles)
    -- sums .lineHeight
    local totalLines = 0 -- defaultLineHeight -- half a line clear top and bottom
    if content then
        for i, contentLine in ipairs(content) do
            local style = content[i].style or defaultStyleName
            local lineHeight = (content[i].lineHeight or ((styles[style] or styles[defaultStyleName]).lineHeight or defaultLineHeight))
            if not contentLine.style 
                and not contentLine.message 
                and not contentLine.lineHeight
                and not contentLine.imgPath
            then
                lineHeight = 0
            end
            totalLines = totalLines + lineHeight
        end
    end
    return totalLines
end

local function getStyleProperties(contentLine, styles)
    -- gets attributes defined nearest
    local style = contentLine.style or defaultStyleName
    local font=((styles[style] or styles[defaultStyleName]).font
            or styles[defaultStyleName].font)
    local textAlign=(contentLine.align 
            or ((styles[style] or styles[defaultStyleName]).align 
            or (styles[defaultStyleName].align or defaultTextAlign)))
    local colorRgba=(contentLine.colorRgba 
            or ((styles[style] or styles[defaultStyleName]).colorRgba 
            or (styles[defaultStyleName].colorRgba or {255,255,255,1.0})))
    local lineHeight=(contentLine.lineHeight 
            or ((styles[style] or styles[defaultStyleName]).lineHeight 
            or (styles[defaultStyleName].lineHeight or defaultLineHeight)))
    if not contentLine.style 
        and not contentLine.message 
        and not contentLine.lineHeight
        and not contentLine.imgPath
    then
        lineHeight = 0
    end

    return style, font, textAlign, colorRgba, lineHeight
end

local function getBoxRadius(c)
    local r=defaultBoxRadius or 0
    if c then
        if c.boxRadius then r = c.boxRadius
        elseif c.boxRadiusLines then r = c.boxRadiusLines * defaultFontSize
        else r = defaultBoxRadius or 0
        end 
    end
    return r
end

local function getBoxProperties(totalLines, xPos, yPos, w, h, r)
    -- determines box dimensions and centreline
    local boxProperties = {}
    local rx, ry = getResolution() -- Gets the resolution of the screen
    boxProperties.boxXpos = (xPos or 0)
    boxProperties.boxYpos = (yPos or 0)
    boxProperties.boxW = (w or (rx - (xPos or 0)))
    boxProperties.boxH = (h or (ry - (yPos or 0)))
    boxProperties.boxRadius = (r or 0)
    return boxProperties

end

local function getTextAreaProperties(totalLines, paddingX, paddingY, box)
    -- determines box dimensions and centreline
    local textArea = {}
    local rx, ry = getResolution() -- Gets the resolution of the screen
    textArea.paddingX = paddingX or 0
    textArea.paddingY = (paddingY or paddingX) or 0
    textArea.xPos = box.boxXpos + textArea.paddingX     -- top left of text area
    textArea.yPos = box.boxYpos + textArea.paddingY     -- top left of text area
    textArea.width = box.boxW - textArea.paddingX * 2   -- text area size
    textArea.height = box.boxH - textArea.paddingY * 2  -- text area size
    textArea.leftPos = textArea.xPos                       -- left inner edge
    textArea.centerPos = textArea.xPos + (textArea.width/2.0) -- centreline
    textArea.rightPos = textArea.xPos + textArea.width  -- right inner edge
    textArea.verticalPitch = (textArea.height/totalLines)
    return textArea
end

local function getImageProperties(content, 
        lineTopEdge, lineHeight, textArea, align)

    local img = {}
    -- API doesn't inspect img so have to be given aspect ratio
    local aspect = (defaultAspectRatio or 1.0) 
    local imgAspectWidth = (content.imgWidth or 0)
    local imgAspectHeight = (content.imgHeight or 0)
    if imgAspectWidth > 0 and imgAspectHeight > 0 then
        aspect = imgAspectWidth / imgAspectHeight
    end
    img.aspect = aspect

    -- image size if scaled to line height
    local imgLineHeight = textArea.verticalPitch * lineHeight
    local imgLineWidth = imgLineHeight * aspect
    if imgLineWidth > textArea.width then
        imgLineWidth = textArea.width
        imgLineHeight = imgLineWidth / aspect
    end

    -- image dimensions
    imgPosX = (content.imgPosX or 0)
    imgPosY = (content.imgPosY or 0)
    if imgPosX>0 and imgPosY>0 then
        -- absolute position, so use absolute size if given
        img.width = content.imgWidth or imgLineWidth
        img.height = content.imgHeight or imgLineHeight
    else
        -- scale to line height 
        img.width = imgLineWidth
        img.height = imgLineHeight
    end

    -- image top left position
    local imgX=0
    local imgAlign = (align or defaultTextAlign)
    if imgAlign=="left" then
        imgX = textArea.leftPos -- left justified
    elseif imgAlign=="right" then
        imgX = textArea.rightPos - img.width -- right justified
    else
        imgX = textArea.centerPos - img.width/2 -- centred
    end
    local imgY = textArea.yPos + lineTopEdge*textArea.verticalPitch -- immediately below previous line
    img.posX = content.imgPosX or imgX
    img.posY = content.imgPosY or imgY

    return img
end

local function drawBox(boxLayer, box)
    -- This draws the box the image and text sit on top of.
    -- Returns boolean if box was drawn, so text color can be adjusted if needed.
    local boxDrawn = false
    local boxBackgroundRgba = box.boxBackgroundColor
    if #boxBackgroundRgba == 3 then table.insert(boxBackgroundRgba, 1.0) end
    if boxLayer and #boxBackgroundRgba == 4 then 
        setNextFillColor(boxLayer, normaliseRgba(boxBackgroundRgba) )
        if (box.boxRadius or 0) > 0 then
            addBoxRounded(boxLayer, box.boxXpos, box.boxYpos, box.boxW, box.boxH, box.boxRadius)
        else
            addBox(boxLayer, box.boxXpos, box.boxYpos, box.boxW, box.boxH)
        end
        boxDrawn = true
    end
    return boxDrawn
end

function writeTextArea(layer, imgLayer, contentLines, styles,
            xPos, yPos, width, height, paddingX, paddingY,
            boxLayer, boxBackgroundColor, boxRadius)
    -- see documentation for parameters    
    local rx, ry = getResolution() -- screen res

    -- get line total from content
    local totalLines = getLineCount(contentLines, styles)
    
    -- set text area parameters
    local box = getBoxProperties(totalLines, xPos, yPos, width, height, boxRadius)
    local textArea = getTextAreaProperties(totalLines, paddingX, paddingY, box)

    -- *** draw background box ***
    
    if boxLayer or boxBackgroundColor or contentLines.boxBackgroundColor then
        local boxLayerUsed = (boxLayer or layer)
        box.boxBackgroundColor = boxBackgroundColor or contentLines.boxBackgroundColor or boxBackgroundDefault or backgroundColor
        box.boxRadius = getBoxRadius(contentLines)
        drawBox(boxLayerUsed, box)
    end

    -- loop over content lines
    local lineTopEdge = 0 -- top of next line
    for i = 1, #contentLines do

        -- *** write one line of text or image ***

        -- get style attributes
        local style, font, textAlign, colorRgba, lineHeight 
            = getStyleProperties(contentLines[i], styles)

        -- next line y pos
        local lineYpos = textArea.yPos + (lineTopEdge + lineHeight/2) * textArea.verticalPitch -- middle of item
        
        -- write text and image to screen
        if contentLines[i].imgPath then
            local img = getImageProperties(contentLines[i], lineTopEdge, lineHeight, textArea, textAlign)
            image = loadImage(contentLines[i].imgPath)
            addImage(imgLayer,image,img.posX,img.posY,img.width,img.height)
        end
        if contentLines[i].message then 
            setNextFillColor(layer, normaliseRgba(colorRgba) )
            if textAlign=="left" then
                setNextTextAlign(layer, AlignH_Left, AlignV_Middle)
                addText(layer, font, contentLines[i].message, textArea.leftPos, lineYpos)
            elseif textAlign=="right" then
                setNextTextAlign(layer, AlignH_Right, AlignV_Middle)
                addText(layer, font, contentLines[i].message, textArea.rightPos, lineYpos)
            else
                setNextTextAlign(layer, AlignH_Center, AlignV_Middle)
                addText(layer, font, contentLines[i].message, textArea.centerPos, lineYpos)
            end
        end
        
        -- next line
        lineTopEdge = lineTopEdge + lineHeight

    end

end 

main()