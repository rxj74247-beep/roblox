local HttpService = game:GetService("HttpService")
local requestFn = request or http_request or (syn and syn.request)
local env = getgenv and getgenv() or _G
local state = env.__CIPHERX_DECOMPILER_STATE

if type(state) ~= "table" then
    state = {}
    env.__CIPHERX_DECOMPILER_STATE = state
end

if type(state.busy) ~= "boolean" then
    state.busy = false
end

if type(state.sequence) ~= "number" then
    state.sequence = 0
end

local function encode(data)
    if crypt then
        if crypt.base64encode then
            return crypt.base64encode(data)
        end
        if crypt.base64 and crypt.base64.encode then
            return crypt.base64.encode(data)
        end
    end
    if base64_encode then
        return base64_encode(data)
    end
    error("No base64 encoder available")
end

local function acquire()
    while state.busy do
        task.wait()
    end
    state.busy = true
    state.sequence += 1
    return state.sequence
end

local function release()
    state.busy = false
end

local function decompile(s)
    if not requestFn then
        return "-- Decompilation failed: request function unavailable"
    end

    local sequence = acquire()
    local ok, result = pcall(function()
        local response = requestFn({
            Url = "https://cipher-x-scripts.com/api/decompiler",
            Method = "POST",
            Headers = {
                ["Content-Type"] = "application/json",
                ["X-Request-Sequence"] = tostring(sequence)
            },
            Body = HttpService:JSONEncode({
                bytecode = encode(getscriptbytecode(s)),
                encoding = "base64",
                mode = "decompile",
                options = {
                    clean = true
                }
            })
        })

        local decoded, body = pcall(function()
            return HttpService:JSONDecode(response.Body)
        end)

        if response.StatusCode == 200 then
            if decoded and body.ok and body.result then
                return body.result
            end
            return response.Body
        end

        if decoded and body.error then
            return "-- Decompilation failed: " .. tostring(body.error)
        end

        if response.StatusCode == 413 then
            return "-- Bytecode is too large"
        end

        if response.StatusCode == 400 then
            return "-- Invalid or unsupported bytecode: " .. tostring(response.Body)
        end

        return "-- Decompilation failed with HTTP " .. tostring(response.StatusCode) .. ": " .. tostring(response.Body)
    end)
    release()

    if ok then
        return result
    end

    return "-- Decompilation failed: " .. tostring(result)
end

env.decompile = decompile
