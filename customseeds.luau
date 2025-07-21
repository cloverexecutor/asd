local url = "https://github.com/cloverexecutor/asd/raw/refs/heads/main/dingbatyou.rbxm"
local data = request({Url = url, Method = "GET"}).Body
writefile("model.rbxm", data)

local model = game:GetObjects(getcustomasset("model.rbxm"))[1]
model.Parent = workspace
print('added model')
