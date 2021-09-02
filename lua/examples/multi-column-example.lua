-- # DU-screen-linesbox
-- Source and usage: https://github.com/kronius12/DU-screen-linesbox
-- License: GNU Public License 3.0
-- Version 1.0.0
--
-- This example creates columns of text and images 
-- on-screen inside boxes with margins, header and footer.

-- ***** 1) EDIT CONTENT HERE *****
-- see documentation for parameters
-- pick from the styles defined in (2) below
-- example table of messages and their styles

local heading={
    {message="DU-screen-linesbox", style="heading" },
    {message="multi-column-example.lua", style="heading" },
    }

local columns={}
local imgHeight = 2.5

table.insert(columns, {
    {message="?", style="elementHeading", lineHeight = 1 },
    {lineHeight = 0.4 },
    {imgPath="resources_generated/iconsLib/elementslib/coreunitstatic256.png", lineHeight = imgHeight-0.8},
    {lineHeight = 0.4 },
    {message="???h", style="element", lineHeight = 1 },
    })

table.insert(columns, {
    {message="?", style="elementHeading", lineHeight = 1 },
    {lineHeight = 0.2 },
    {imgPath="resources_generated/iconsLib/elementslib/coreunitstatic256.png", lineHeight = imgHeight-0.4},
    {lineHeight = 0.2 },
    {message="???h", style="element", lineHeight = 1 },
    })

table.insert(columns, {
    {message="?", style="elementHeading", lineHeight = 1 },
    {imgPath="resources_generated/iconsLib/elementslib/coreunitstatic256.png", lineHeight = imgHeight},
    {message="???h", style="element", lineHeight = 1 },
    })

local footer = {
{message="Source and usage: ", style="details"},
{message="https://github.com/kronius12", style="details"},
{message="/DU-screen-linesbox", style="details"},
}

-- ***** 2) STYLE DEFS *****

-- default parameters
backgroundColor = {80,80,20}  -- screen background
defaultFontSize = 40          -- reduce this to fit more text
defaultLineHeight = 1.0       -- a standard line is 1 line high,
                              -- or change to defaultFontSize if you'd rather work in pixels
defaultPadding = 20           -- whitespace inside box
defaultTextAlign = "center"   -- text and images

local function getStyles()
    -- you could use functions for various style sets
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

    return styles
end

-- ***** 3) CALL IT ALL *****
local function main()
    local margin = 20
    local padding = defaultPadding
    
    local rx, ry = getResolution() -- Gets the resolution of the screen
    local boxLayer = createLayer()   -- Creates a new layer, index 1
    local imgLayer = createLayer()   -- Creates a layer on top of boxLayer
    local textLayer = createLayer()  -- Creates a layer on top of boxLayer and imgLayer
    local styles = getStyles()       -- Table of styles for this text
    setBackgroundColor(normaliseRgb(backgroundColor))
    
    -- *** EDIT THIS ***
    -- This works out the position of each text box as it goes
    local boxBackground = {0,48,120, 1}
    
    -- Total height of text
    local nHeadingLines = getLineCount(heading, styles)
    local nColLines = getLineCount(columns[1], styles) -- assume they're the same
    local nFooterLines = getLineCount(footer, styles)
    local totalLines = nHeadingLines + nColLines + nFooterLines
    
    -- Total white space top, between boxes, and bottom
    local totalMargins = margin * 2
    if nHeadingLines > 0 then totalMargins = totalMargins + margin end -- after heading
    if nColLines > 0 then totalMargins = totalMargins + margin end -- after text
    
    local totalPadding = 0
    if nHeadingLines > 0 then totalPadding = totalPadding + padding * 2 end -- heading
    if nColLines > 0 then totalPadding = totalPadding + padding * 2 end -- text
    -- if nFooterLines > 0 then totalPadding = totalPadding + padding * 2 end -- footer no padding
    
    -- Total pitch
    local textPitch = (ry - totalMargins - totalPadding) / totalLines    
    local nextBoxTop=margin
    local boxHeight=0

    -- write heading in a box
    if nHeadingLines > 0 then
        boxHeight=nHeadingLines*textPitch + padding*2
        writeTextArea(textLayer, imgLayer, heading, styles, 
            margin, nextBoxTop, 
            rx - 2*margin, boxHeight,
            padding, padding, 
            boxLayer, boxBackground)
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

            writeTextArea(textLayer, imgLayer, content, styles,
                offset, nextBoxTop,
                boxWidth, boxHeight,
                padding, padding, 
                boxLayer, boxBackground)
        end
        nextBoxTop = nextBoxTop + boxHeight + margin
    end
    
    -- write footer no box
    if nFooterLines > 0 then
        boxHeight = nFooterLines*textPitch
        writeTextArea(textLayer, imgLayer, footer, styles,
            0, nextBoxTop,
            rx, boxHeight,
            padding, 0)
        nextBoxTop = nextBoxTop + boxHeight + margin
    end

    -- *** END OF EDIT THIS ***
end

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

        return style, font, textAlign, colorRgba, lineHeight
end

local function getBoxProperties(totalLines, xPos, yPos, width, height)
    -- determines box dimensions and centreline
    local boxProperties = {}
    local rx, ry = getResolution() -- Gets the resolution of the screen
    boxProperties.boxXpos = (xPos or 0)
    boxProperties.boxYpos = (yPos or 0)
    boxProperties.boxW = (width or (rx - (xPos or 0)))
    boxProperties.boxH = (height or (ry - (yPos or 0)))
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

local function getImageProperties(content, lineTopEdge, lineHeight, textArea, align)

    local img = {}
    local aspect = 1.0 -- API doesn't inspect img so work it out
    local imgAspectWidth = (content.width or 0)
    local imgAspectHeight = (content.height or 0)
    if imgAspectWidth > 0 and imgAspectHeight > 0 then
        aspect = content.imgAspectWidth / content[i].imgAspectHeight
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
    if content.imgPosX and content.imgPosY then
        -- absolute position, so use absolute size if given
        img.width = content.width or imgLineWidth
        img.height = content.height or imgLineHeight
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
        addBox(boxLayer, box.boxXpos, box.boxYpos, box.boxW, box.boxH)
        boxDrawn = true
    end
    return boxDrawn 
end

function writeTextArea(layer, imgLayer, contentLines, styles, xPos, yPos, width, height, paddingX, paddingY, boxLayer, boxBackgroundRgba)
    -- see documentation for parameters    

    -- get line total from content
    local totalLines = getLineCount(contentLines, styles)
    
    -- set text area parameters
    local rx, ry = getResolution() -- Gets the resolution of the screen

    local box = getBoxProperties(totalLines, xPos, yPos, width, height)
    local textArea = getTextAreaProperties(totalLines, paddingX, paddingY, box)

    -- *** draw background box ***
    if boxLayer then
        box.boxBackgroundColor = boxBackgroundRgba or {}
        drawBox(boxLayer, box)
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