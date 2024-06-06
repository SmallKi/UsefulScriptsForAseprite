    -- 定义交换图层内容的函数
function swapLayers(layer1, layer2)
    -- app.alert("这里")
    -- 获取图层的像素数据
    local frames = app.range.frames 

    local data1 = {}
    local data2 = {}
    for i,layer in ipairs(app.sprite.layers) do
        if layer.name == layer1 then 
            for j, frame in ipairs(frames) do
                local cel = layer:cel(frame.frameNumber)
                table.insert(data1, cel)
            end
        end 

        if layer.name == layer2 then 
            for j, frame in ipairs(frames) do
                -- app.alert(tostring(frame.frameNumber) .." " .. layer.name)
                -- local d = layer:cel(frame.frameNumber)
                local cel = layer:cel(frame.frameNumber)
                table.insert(data2, cel)
            end
        end 
    end
    
    for i,cel1 in ipairs(data1) do
        local cel2 = data2[i]
        local mid_pos = cel1.position
        local mid = cel1.image:clone()
        -- app.alert("image:"..cel1.image) 
        cel1.image = cel2.image
        cel1.position = cel2.position
        cel2.image = mid
        cel2.position = mid_pos
    end
end

-- 创建一个自定义对话框，让用户选择图层
function chooseLayers()
    local layers = app.sprite.layers
    local layerNames = {}
    for i, layer in ipairs(layers) do
        table.insert(layerNames, layer.name)
    end

    local dialog = Dialog("Change Layers Content")
    local data = dialog:combobox{
            id = "layer1", 
            label = "layer1:",
            options = layerNames,
            option = #app.range.layers >= 1 and app.range.layers[1].name or ""
        }
        :combobox{
            id = "layer2", 
            label = "layer2:",
            options = layerNames,
            option = #app.range.layers >= 2 and app.range.layers[2].name or ""
        }
        :button{id="swap", text = "Change"}
        :show().data

    if data.swap then
        swapLayers(data.layer1, data.layer2) 
        dialog:close()
    end
end

-- 调用函数，弹出窗口让用户选择图层
chooseLayers()