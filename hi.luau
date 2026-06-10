local __TypeFn, luau = type, require('@std/luau')
local loadstring, fs, Process = function(src, chunkname)
    return luau.load(luau.compile(src) or src, chunkname)
end, require('@std/fs'), require('@lute/process')
local json = require('@std/json')
task = require('@std/task')
require = function() end
_G.require = function() end

local Setmetatable, Clock, Typeof, Tostring, Tonumber, Next, Unpack, RawGet, Gsub, Rep, Format, Sub, Match, Split, Char, Byte, Lower, Upper, Find, Insert, Concat, Move, Pack, Remove, Wrap, Yield, DebugInfo, select = setmetatable, os.clock, typeof, tostring, tonumber, next, unpack, rawget, string.gsub, string.rep, string.format, string.sub, string.match, string.split, string.char, string.byte, string.lower, string.upper, table.find, table.insert, table.concat, table.move, table.pack, table.remove, coroutine.wrap, coroutine.yield, debug.info, select
local Alphabet, next, _print = Split('abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789', ''), next, print

print = function(...)
    local function Color(txt, code)
        return string.format('\27[%sm%s\27[0m', tostring(code), tostring(txt))
    end

    local Line, Name = DebugInfo(2, 'ln')
    local ColoredName, ColorLine = Color(Name == '' and '???' or Name, 32), Color(string.format('line %s', tostring(Line)), 35)
    local FinalText = string.format('[ %s @ %s ]:', tostring(ColoredName), tostring(ColorLine))

    _print(FinalText, ...)
end

local function GenerateId(len)
    local txt = ''

    for i = 1, len or 6 do
        txt = txt .. Alphabet[math.random(1, #Alphabet)]
    end

    return txt
end
local function RE_Safe(Str, FullChars)
    local Chars = (FullChars and '%()[].-+^*$?' or '%'):split('')

    for _, char in next, Chars do
        Str = Str:gsub('%' .. char, '%%' .. (char == '%' and '%' or '') .. char)
    end

    return Str
end
local function Strip(Str, IgnoreStart)
    local start_idx, end_idx, Split, Spaces = 1, #Str, Str:split(''), {
        [' '] = true,
        ['\t'] = true,
        ['\r'] = true,
        ['\n'] = true,
    }

    if not IgnoreStart then
        for i = 1, #Split do
            if not Spaces[Split[i] ] then
                start_idx = i

                break
            end
        end
    end

    for i = #Split, 1, -1 do
        if not Spaces[Split[i] ] then
            end_idx = i

            break
        end
    end

    return Str:sub(start_idx, end_idx)
end

local TraceId, FileSystem, Settings = GenerateId(7), {
    read = fs.readFileToString,
    write = fs.writeStringToFile,
}, {
    hookOpValue = 'spy',
    hookOp = true,
    explore_funcs = true,
    spy_exec_only = true,
    minifier = true,
    varRenamer = false,
    raw = false,
    max_ops = 10500,
    max_while_count = 100000,
    saveFails = false,
    env_index = false,
}

local function StrToValue(Str)
    if Str == 'false' then
        return false
    elseif Str == 'true' then
        return true
    elseif Str == 'nil' then
        return nil
    elseif tonumber(Str) then
        return tonumber(Str)
    else
        return Str
    end
end

for index, arg in Process.args do
    local k, v = Match(arg, '--([%w_]+)=(.+)')
    local Arg = Sub(arg, 3)

    if v then
        Settings[k] = StrToValue(v)
    else
        Settings[Arg] = true
    end
end

local Top, ExecEnv, newcclosure = {add_if_comment = false}, {
    'game',
    'workspace',
    'script',
    'Instance',
    'Enum',
    'Vector3',
    'Vector2',
    'Vector3int16',
    'Vector2int16',
    'UDim',
    'UDim2',
    'CFrame',
    'Color3',
    'BrickColor',
    'Ray',
    'Axes',
    'Faces',
    'Region3',
    'Region3int16',
    'Rect',
    'NumberRange',
    'PhysicalProperties',
    'cache',
    'cloneref',
    'compareinstances',
    'checkcaller',
    'clonefunction',
    'getcallingscript',
    'getscriptclosure',
    'hookfunction',
    'iscclosure',
    'islclosure',
    'isexecutorclosure',
    'loadstring',
    'newcclosure',
    'rconsoleclear',
    'rconsolecreate',
    'rconsoledestroy',
    'rconsoleinput',
    'rconsoleprint',
    'rconsolesettitle',
    'crypt',
    'debug',
    'readfile',
    'listfiles',
    'writefile',
    'makefolder',
    'appendfile',
    'isfile',
    'isfolder',
    'delfolder',
    'delfile',
    'loadfile',
    'dofile',
    'isrbxactive',
    'mouse1click',
    'mouse1press',
    'mouse1release',
    'mouse2click',
    'mouse2press',
    'mouse2release',
    'mousemoveabs',
    'mousemoverel',
    'mousescroll',
    'fireclickdetector',
    'getcallbackvalue',
    'getconnections',
    'getcustomasset',
    'gethiddenproperty',
    'sethiddenproperty',
    'syn',
    'gethui',
    'getinstances',
    'getnilinstances',
    'isscriptable',
    'setscriptable',
    'setrbxclipboard',
    'getrawmetatable',
    'hookmetamethod',
    'getnamecallmethod',
    'isreadonly',
    'setrawmetatable',
    'setreadonly',
    'identifyexecutor',
    'lz4compress',
    'lz4decompress',
    'messagebox',
    'request',
    'setclipboard',
    'setfpscap',
    'getgc',
    'getgenv',
    'getloadedmodules',
    'getrenv',
    'getrunningscripts',
    'getscriptbytecode',
    'getscripthash',
    'getscripts',
    'getsenv',
    'getthreadidentity',
    'setthreadidentity',
    'Drawing',
    'isrenderobj',
    'getrenderproperty',
    'setrenderproperty',
    'cleardrawcache',
    'WebSocket',
    'getfenv',
    'coroutine',
    'math',
    'string',
    'table',
    'os',
    'utf8',
    'bit32',
    'buffer',
    'TweenInfo',
    'RaycastParams',
    'OverlapParams',
    'Random',
    'ColorSequence',
    'ColorSequenceKeypoint',
    'NumberSequenceKeypoint',
    'NumberSequence',
    'SharedTable',
    'shared',
    'Font',
    'elapsedTime',
    'settings',
    'tick',
    'time',
    'typeof',
    'UserSettings',
    'version',
    'warn',
    'plugin',
    'shared',
    'assert',
    'error',
    'gcinfo',
    'getmetatable',
    'ipairs',
    'newproxy',
    'next',
    'pairs',
    'pcall',
    'print',
    'rawequal',
    'rawget',
    'rawlen',
    'rawset',
    'require',
    'select',
    'setmetatable',
    'tostring',
    'unpack',
    'xpcall',
    '_G',
    '_VERSION',
    'Game',
    'Workspace',
    'gethwid',
    'delay',
    "Path2DControlPoint"
}, function(Function)
    local a = Wrap(function(...)
        local b = {
            Yield(),
        }

        while true do
            b = {
                Yield(Function(Unpack(b))),
            }
        end
    end)

    a()

    return a
end
local NewCClosure, Internal, Addresses, ParamsUsed, Values, Output, Id, ExpressionId, ExpressionHooks, Types = newcclosure, {}, {}, {}, {}, {}, 0, 0, {}, {
    table = {
        'syn',
        'syn.crypt',
        'syn.oth',
        'synapse',
        'krnl',
        'fluxus',
        'protosmasher',
        'debug',
        'bit',
        'Drawing',
        'WebSocket',
        'cache',
        'shared',
        '_G',
        'syn.crypto',
        'crypt',
        'crypto',
        'getfenv()',
        'getgenv()',
        'getrenv()',
        'http',
        'math',
        'string',
        'table',
        'os',
        'coroutine',
    },
    ['function'] = {
        'getgenv',
        'getrenv',
        'getreg',
        'getgc',
        'getinstances',
        'getnilinstances',
        'getscripts',
        'getloadedmodules',
        'getconnections',
        'firesignal',
        'fireclickdetector',
        'firetouchinterest',
        'replicatesignal',
        'getsenv',
        'gettenv',
        'getmenv',
        'getcallingscript',
        'syn.cache_replace',
        'syn.cache_invalidate',
        'syn.set_thread_identity',
        'syn.get_thread_identity',
        'syn.is_cached',
        'syn.protect_gui',
        'syn.unprotect_gui',
        'syn.queue_on_teleport',
        'syn.secure_call',
        'syn.create_secure_function',
        'syn.run_secure_function',
        'syn.request',
        'syn.write_clipboard',
        'syn.is_beta',
        'hookfunction',
        'hookmetamethod',
        'clonefunction',
        'newcclosure',
        'setstackhidden',
        'isfunctionhooked',
        'restorefunction',
        'syn.crypt.base64',
        'syn.crypt.hex',
        'syn.crypt.lz4',
        'syn.crypt.zstd',
        'syn.crypt.derive',
        'syn.crypt.url',
        'syn.crypt.user.prompt',
        'syn.crypt.sign.detached',
        'syn.crypt.seal',
        'syn.crypt.custom',
        'mouse1click',
        'mouse1press',
        'mouse1release',
        'mouse2click',
        'mouse2press',
        'mouse2release',
        'mousemoveabs',
        'mousemoverel',
        'mousescroll',
        'fireclickdetector',
        'fireproximityprompt',
        'firetouchinterest',
        'iswindowactive',
        'keypress',
        'keyrelease',
        'isnetworkowner',
        'readfile',
        'writefile',
        'appendfile',
        'loadfile',
        'listfiles',
        'isfile',
        'isfolder',
        'makefolder',
        'delfolder',
        'delfile',
        'setclipboard',
        'setrbxclipboard',
        'setfflag',
        'getnamecallmethod',
        'setnamecallmethod',
        'saveinstance',
        'gethiddenproperty',
        'sethiddenproperty',
        'setsimulationradius',
        'debug.getupvalue',
        'debug.getupvalues',
        'debug.getstack',
        'debug.getproto',
        'debug.getprotos',
        'Drawing.new',
        'Drawing.Fonts',
        'http.request',
        'WebSocket.connect',
        'typeof',
        'elapsedTime',
        'UserSettings',
        'warn',
        'assert',
        'error',
        'gcinfo',
        'getmetatable',
        'setmetatable',
        'ipairs',
        'pairs',
        'next',
        'newproxy',
        'pcall',
        'xpcall',
        'print',
        'rawequal',
        'rawget',
        'rawset',
        'rawlen',
        'require',
        'select',
        'tick',
        'time',
        'coroutine.create',
        'coroutine.resume',
        'coroutine.yield',
        'request',
    },
    Instance = {
        'game',
        'workspace',
        'Game',
        'Workspace',
        'game.Workspace',
        'Game.Workspace',
    },
}

local function GetActualPath(Path)
    local Result = Path

    while true do
        local Value = Values[Result]

        if not Value then
            break
        end

        Result = Value.Value
    end

    return Result
end
local function GetAddress(P, T)
    local Address = Addresses[P] or Format('%s0x%s', ((T == 'function' or T == 'table') and string.format('%s: ', tostring(T)) or ''), Match(tostring(function() end), '0x([A-Fa-f0-9]+)'))

    Addresses[P] = Address

    return Address
end
local function GetType(Name)
    local OldType = Typeof(Name)

    if OldType ~= 'string' then
        return OldType
    end

    for Type, List in next, Types do
        if Find(List, Name) then
            return Type
        end
    end
end
local function Main(Source, NestCount, CurrentIndent, Original)
    local OutFile = Settings.outfile or 'out2.lua'

    CurrentIndent = CurrentIndent or 0
    NestCount = NestCount or 0

    local LoopCount, OpCount = 0, 0

    local function OpCountCheck()
        if OpCount >= Settings.max_ops then
            print('stopp')
            error('Too many operations.', 2)
        end
    end

    local Tab, ParamSuffix = Rep('    ', CurrentIndent), NestCount == 0 and '' or string.format('_%s', tostring(NestCount))

    local function IsInternal(x)
        local i = Internal[x]

        if i then
            Use(i, '__tostring')
        end

        return i
    end
    local function GetVarID()
        Id = Id + 1

        return string.format('var%s%s', tostring(Id), tostring(ParamSuffix))
    end
    local function Append(a)
        Output[#Output + 1] = Tab .. a

        if Settings.saveFails and Original then
            task.spawn(fs.writeStringToFile, OutFile, Concat(Output, '\n'))
        end
    end

    function Beautify(Data, Indent, Args)
        Indent = Indent or CurrentIndent
        Args = Typeof(Args) == 'table' and Args or {}

        local FuncName, Minify = Args.FuncName, Args.Minify

        local function IsRecursive(t)
            local visited = {}

            local function check(tbl)
                if visited[tbl] then
                    return true
                end

                visited[tbl] = true

                for _, v in next, tbl do
                    if type(v) == 'table' then
                        if check(v) then
                            return true
                        end
                    end
                end

                visited[tbl] = nil

                return false
            end

            return check(t)
        end

        local Types = {
            table = function()
                local Int = IsInternal(Data)

                if Int then
                    return Int
                end
                if IsRecursive(Data) then
                    return '{ "recursive table" }'
                end

                local Options, Result, NewLine, Tab, Count, Dict = {Minify = true}, '{', Minify and ' ' or '\n', Minify and '' or Rep('    ', Indent), 0

                for k, v in Next, Data do
                    Count = Count + 1

                    local Base, Fixed = string.format('%s%s', tostring(NewLine), tostring(Tab)), IsWeird(k) and string.format('[%s]', tostring(Beautify(k, Indent, Options))) or k
                    local Key = Count == k and not Dict and Base or string.format('%s%s = ', tostring(Base), tostring(Fixed))

                    if Count ~= k then
                        Dict = true
                    end

                    Result = Result .. string.format('%s%s,', tostring(Key), tostring(Beautify(v, Indent + 1, {FromBeautify = true})))
                end

                local End = Minify and ' }' or string.format('\n%s}', tostring(Rep('    ', Indent - 1)))

                return Count == 0 and '{}' or Sub(Result, 1, -2) .. End
            end,
            string = function()
                local Replaced = Gsub(Data, '\\', '\\\\')

                Replaced = Gsub(Replaced, '[\n\b\t\v\f"\r]', {
                    ['\n'] = '\\n',
                    ['\b'] = '\\b',
                    ['\t'] = '\\t',
                    ['\v'] = '\\v',
                    ['\f'] = '\\f',
                    ['"'] = '\\"',
                    ['\r'] = '\\r',
                })

                if #Replaced > 1000 then
                    Replaced = Sub(Replaced, 1, 1000) .. string.format('..( %s bytes left)', tostring(#Replaced - 1000))
                end

                return ('"' .. Replaced .. '"')
            end,
            ['function'] = function()
                local S, N = DebugInfo(Data, 'sn')

                N = FuncName or N

                if not Settings.explore_funcs then
                    return 'function()--[[enable explore funcs to view this function]]end', N
                end
                if S == '[C]' then
                    return N == '' and '(function()--[[cclosure]]end)' or N, N
                end

                local Old, OldParams = Output, ParamsUsed

                Output, ParamsUsed = {}, {}

                local CallBody, Return = Main(Data, NestCount + 1, Indent)
                local FunctionIndent, Sorted = Args.FromBeautify and Rep('    ', Indent) or Rep(' ', 4), {}

                for k in next, ParamsUsed do
                    table.insert(Sorted, k)
                end

                table.sort(Sorted, function(a, b)
                    return (Tonumber(Match(a, 'arg(%d+)')) or math.huge) < (Tonumber(Match(b, 'arg(%d+)')) or math.huge)
                end)

                local ParamList = {}

                for _, key in next, Sorted do
                    Insert(ParamList, ParamsUsed[key] and key or '_')
                end

                for i = #ParamList, 1, -1 do
                    if ParamList[i] == '_' then
                        Remove(ParamList, i)
                    else
                        break
                    end
                end

                local Params, Body = Concat(ParamList, ', '), ''

                if FuncName then
                    if IsWeird(FuncName) then
                        Body = Body .. string.format('%s = function', tostring(Index(FuncName)))
                    else
                        Body = Body .. string.format('function %s', tostring(FuncName))
                    end
                else
                    Body = Body .. 'function'
                end

                Body = Body .. string.format('(%s)\n', tostring(Params))

                if #CallBody > 0 then
                    Output = {}

                    for _, Line in next, Split(CallBody, '\n')do
                        Insert(Output, Line)
                    end
                end

                for _, v in next, Output do
                    Body = Body .. FunctionIndent .. v .. '\n'
                end

                if Return then
                    Body = Body .. FunctionIndent .. Return .. '\n'
                end

                Body, Output, ParamsUsed = Body .. (Indent > 1 and Rep('    ', Indent - 1) or '') .. 'end', Old, OldParams

                return Body
            end,
            userdata = function()
                local mt = getmetatable(Data)

                if mt then
                    return string.format('get_user_data(%s)', tostring(Beautify(mt, Indent + 1)))
                end

                return Beautify(Tostring(Data))
            end,
            number = function()
                if Tonumber(Format('%.4f', Data)) ~= Data then
                    Data = math.ceil(Data)
                end

                local str = Tostring(Data)

                return str == '-inf' and '-math.huge' or str == 'inf' and 'math.huge' or str
            end,
        }
        local Value = Types[Typeof(Data)]
        local Return = Value and {
            Value(),
        } or {
            Tostring(Data),
        }

        return Unpack(Return)
    end

    local function BeautifyTuple(...)
        local Out, Args = '', Pack(...)

        for i = 1, Args.n do
            Out = Out .. string.format('%s, ', tostring(Beautify(Args[i], CurrentIndent + 1)))
        end

        return Sub(Out, 1, -3)
    end

    function IsWeird(Key)
        return Key == '' or Match(Key, '[^_%w]') or Match(Key, '%d') == Sub(Key, 1, 1)
    end
    function Index(Key, Path)
        local Beauty = IsInternal(Key)

        if Beauty then
            return Path and string.format('%s[%s]', tostring(Path), tostring(Beauty)) or Beauty
        end

        local IsWeirdo, IsVararg = IsWeird(Key), Path == '...'

        if IsVararg then
            Path = '(...)'
        end

        return IsWeirdo and string.format('%s[%s]', tostring(Path or 'getfenv()'), tostring(Beautify(Key))) or string.format('%s%s', tostring(Path and Path .. '.' or ''), tostring(Key))
    end

    local Vars = {}

    local function GetVar(Idx)
        local Value = Vars[Idx] or 1

        Vars[Idx] = Value + 1

        return Value == 1 and '' or Value
    end
    local function SplitIDX(str)
        str = tostring(str)

        local Result = {}

        for Part in str:gmatch('[^%.%[]+')do
            local Key = Part:match('^%s*(.-)%s*$')

            if Sub(Key, -1) == ']' then
                Key = Match(Key, '%[(.-)%]') or Key
                Key = Gsub(Key, '^["\'](.-)["\']$', '%1')
            end

            Insert(Result, Key)
        end

        return Result
    end
    local function GenerateName(str, Method)
        while true do
            local Value = (Values[str] or {}).Value

            if Value then
                str = Value
            else
                break
            end
        end

        Method = Gsub(Method, '%A', '') == '' and (Method .. GetVar(Method) .. ParamSuffix) or Method

        if str == 'GetService' then
            return Method .. Id
        elseif Method == 'iter' then
            return str .. Id
        end

        return GetVarID()
    end
    local function Define(Var, Value, Tag)
        Values[Var] = {
            Value = Value,
            Tag = Tag,
            Line = #Output,
            Usage = 0,
        }
    end

    function Use(Var, Tag, Increment, Val)
        local Value = Values[Var]

        if not Value then
            return Define(Var, Val, Tag)
        end
        if Value.Usage == 0 or Increment then
            Value.Usage = (Increment and Value.Usage or 0) + 1
        end
    end

    local Spied = {}

    local function Spy(Path, Flags)
        if Spied[Path] then
            return Spied[Path]
        end

        Flags = Flags or {}

        local ISP = Flags.Param

        local function Arth(Symbol)
            return NewCClosure(function(a, b)
                if GetType(Path) == 'Instance' then
                    error('attempt to perform arithmetic on a Instance value', 2)
                end

                local Value, Var = string.format('%s %s %s', tostring(Beautify(a)), tostring(Symbol), tostring(Beautify(b))), GetVarID()

                Append(string.format('local %s = %s', tostring(Var), tostring(Value)))
                Define(Var, Value, '__arth')

                return Spy(Var)
            end)
        end

        function Iter(_, Key)
            local Path = RawGet(_, 'P')
            local Value, IterFunc = Values[Path] or {}, Path

            if not Key then
                if Value.Tag == '__call' and Value.Usage == 0 then
                    IterFunc = Value.Value
                    Output[Value.Line] = nil
                end
            else
                local Arg1 = Path

                if Value.Usage == 0 then
                    Arg1 = Value.Value or Path
                end

                IterFunc = Key == 'next' and string.format('next, %s', tostring(Arg1)) or string.format('%s(%s)', tostring(Key), tostring(Arg1))
            end

            local Iv, Vv = GenerateName('k', 'iter'), GenerateName('val', 'iter')

            Append(string.format('for %s, %s in %s do', tostring(Iv), tostring(Vv), tostring(IterFunc)))

            local Called, Indent = nil, CurrentIndent

            Tab = Rep('    ', Indent + 1)

            return function(_, k)
                if Called then
                    Tab = Rep('    ', Indent)

                    Append('end')

                    return
                else
                    Called = true
                end

                return Spy(Iv), Spy(Vv)
            end
        end

        local Mt = {
            __index = function(_, Key)
                if Path == 'workspace' and Key == 'subgmaallshaha' then
                    return
                end

                local Var, Value = GetVarID(), Index(Key, Path)

                Use(Path, '__index', true)
                Append(string.format('local %s = %s', tostring(Var), tostring(Value)))
                Define(Var, Value, '__index')

                return Path == 'workspace' and Key == 'FallenPartsDestroyHeight' and -500 or Spy(Var)
            end,
            __newindex = function(_, Key, Value)
                local P = IsInternal(Value)

                Use(Path, '__newindex', true)

                if Values[P] then
                    do
                        local __DARKLUA_VAR = Values[P]

                        __DARKLUA_VAR.Usage = __DARKLUA_VAR.Usage - 1
                    end
                end

                local InternalKey = IsInternal(Key)
                local Var = InternalKey and string.format('%s[%s]', tostring(Path), tostring(InternalKey)) or Index(Key, Path)

                Append(string.format('%s = %s', tostring(Var), tostring(Beautify(Value, CurrentIndent + 1))))
                Use(Var, '__newindex', true)
            end,
            __call = function(_, ...)
                Use(Path, '__call')

                if GetType(Path) == 'Instance' then
                    error('attempt to call a Instance value', 2)
                end

                local Path = Path == '...' and '(...)' or Path
                local Dots = SplitIDX(GetActualPath(Path))
                local Self, Args, Tuple, Var = Concat(Move(Dots, 1, #Dots - 1, 1, {}), '.'), Pack(...), {}

                for i = 1, Args.n do
                    local Arg = Args[i]
                    local b = Beautify(Arg, CurrentIndent + 1)

                    Insert(Tuple, b)
                end

                local FirstArg, SecondArg = Args[1], Args[2]

                if Beautify(FirstArg) == Self then
                    local Method = Dots[#Dots]

                    Path = string.format('%s:%s', tostring(Self), tostring(Method))
                    Var = GenerateName(Method, Typeof(SecondArg) == 'string' and SecondArg or '__call')

                    Remove(Tuple, 1)
                end

                Var = Var or GenerateName(Path, Typeof(FirstArg) == 'string' and FirstArg or '__call')

                local Value = string.format('%s(%s)', tostring(Path), tostring(Concat(Tuple, ', ')))

                Append(string.format('local %s = %s', tostring(Var), tostring(Value)))
                Define(Var, Value, '__call')

                return Spy(Var)
            end,
            __add = Arth('+'),
            __sub = Arth('-'),
            __mul = Arth('*'),
            __div = Arth('/'),
            __idiv = Arth('//'),
            __pow = Arth('^'),
            __concat = Arth('..'),
            __mod = Arth('%'),
            __tostring = function(_)
                Use(Path, '__tostring')

                return Path
            end,
            __unm = function(_)
                local Var = GenerateName(P, 'unm')

                Append(string.format('local %s = -%s', tostring(Var), tostring(Path)))

                return Spy(Var)
            end,
            __iter = Iter,
            __metatable = {},
        }

        for i, Method in Next, Mt do
            local __DARKLUA_CONTINUE_20 = false

            repeat
                if Typeof(Method) ~= 'function' then
                    __DARKLUA_CONTINUE_20 = true

                    break
                end

                Mt[i] = function(_, ...)
                    OpCount = OpCount + 1

                    OpCountCheck()

                    if ISP then
                        ParamsUsed[Path] = true
                    end

                    return Method(_, ...)
                end
                __DARKLUA_CONTINUE_20 = true
            until true

            if not __DARKLUA_CONTINUE_20 then
                break
            end
        end

        local Object = Setmetatable({
            P = Path,
            ISP = ISP,
        }, Mt)

        Spied[Path] = Object

        if ISP then
            ParamsUsed[Path] = false
        end

        Internal[Object] = Path

        return Object
    end
    local function SpyParams(Amount)
        local Out = {}

        for i = 1, Amount do
            Out[#Out + 1] = Spy(string.format('arg%s%s', tostring(i), tostring(ParamSuffix)), {Param = true})
        end

        return Unpack(Out)
    end
    local function CreateFunction(Callback, Path)
        Path = Path or '(function()end)'

        local Meta = Setmetatable({}, {
            __call = function(_, ...)
                return Callback(...)
            end,
            __tostring = function()
                return Path
            end,
        })

        Internal[Meta] = Path

        return Meta
    end

    local IsFile = Typeof(Source) == 'string'

    local function SafeWrap(f, path, isCore)
        if Typeof(f) ~= 'function' then
            return
        end

        local name = DebugInfo(f, 'n')

        local function helper(...)
            local var, value = GenerateName(name, 'call'), string.format('%s(%s)', tostring(path), tostring(BeautifyTuple(...)))

            Append(string.format('local %s = %s', tostring(var), tostring(value)))
            Define(var, value, '__call')

            return Spy(var)
        end

        return CreateFunction(function(...)
            local args = Pack(...)

            for i = 1, args.n do
                local arg = args[i]

                if IsInternal(arg) and (not isCore or not RawGet(arg, 'ISP')) then
                    local value = helper(...)

                    if value then
                        return value
                    end
                end
            end

            return f(...)
        end, path)
    end

    local Locked

    local function AddVar(Name1, Name2, Value, Tag)
        local Var = GenerateName(Name1, Name2)

        Append(string.format('local %s = %s', tostring(Var), tostring(Value)))
        Define(Var, Value, Tag)

        return Var
    end

    local function CreateLoader(Name)
        local Loader = Setmetatable({P = Name}, {
            __call = function(_, a, b)
                local IsString, IsWeird, Value, Args = Typeof(a) == 'string', b and Typeof(b) ~= 'string', string.format('%s(', tostring(Name)), {a, b}

                Value = Value .. string.format('%s)', tostring(BeautifyTuple(Unpack(Args))))

                if IsString and not IsWeird then
                    return Setmetatable({P = Value}, {
                        __call = function(_, ...)
                            Append(string.format('%s(%s)', tostring(Value), tostring(BeautifyTuple(...))))

                            local _a = a

                            if not Settings.raw then
                                local S, HookOpDoneString = pcall(HookOpHandler, a)

                                if S then
                                    a = HookOpDoneString
                                end
                            end

                            local Returned = {
                                setfenv(loadstring(a, b), Locked)(...),
                            }
                            local Message = Returned[2]

                            if not Returned[1] then
                                Message = Sub(_a, 1, 1) == '\n' and Gsub(Message, ':1:', ':2:') or Message

                                return false, Message
                            end

                            return Unpack(Returned)
                        end,
                        __tostring = function()
                            return Value
                        end,
                    })
                end

                return function(...)
                    local Vars, Str = {}, 'local '

                    for _ = 1, 3 do
                        local Var = GetVarID()

                        Str = Str .. Var .. ', '

                        Insert(Vars, Spy(Var))
                    end

                    Append(string.format('%s = %s(%s)', tostring(Sub(Str, 1, -3)), tostring(Value), tostring(BeautifyTuple(...))))

                    return Unpack(Vars)
                end
            end,
            __tostring = function()
                return Name
            end,
        })

        Internal[Loader] = Name

        return Loader
    end

    local Loadstring = CreateLoader('loadstring')

    local function FastComp(Symbol)
        local function TryCompare(v1, v2)
            if Symbol == '<' then
                return pcall(function()
                    return v1 < v2
                end)
            elseif Symbol == '>' then
                return pcall(function()
                    return v1 > v2
                end)
            elseif Symbol == '<=' then
                return pcall(function()
                    return v1 <= v2
                end)
            elseif Symbol == '>=' then
                return pcall(function()
                    return v1 >= v2
                end)
            end

            return false, nil
        end

        return function(a, b)
            local A, B, v1, v2 = IsInternal(a), IsInternal(b), a, b

            if A or B then
                if A then
                    Use(A, '__comp', true)

                    v1 = RawGet(a, 'V')
                end
                if B then
                    Use(B, '__comp', true)

                    v2 = RawGet(b, 'V')
                end
                if v1 == nil then
                    v1 = a
                end
                if v2 == nil then
                    v2 = b
                end

                local Var = AddVar('Comp', Symbol, string.format('%s %s %s', tostring(A or Beautify(a)), tostring(Symbol), tostring(B or Beautify(b))), '__comp')
                local Return, Success, Result = Spy(Var), TryCompare(v1, v2)

                if Success then
                    rawset(Return, 'V', Result)
                end

                return Return
            end

            local Success, Result = TryCompare(v1, v2)

            if Success then
                return Result
            end

            return Spy(AddVar('Comp', Symbol, string.format('%s %s %s', tostring(Beautify(a)), tostring(Symbol), tostring(Beautify(b))), '__comp'))
        end
    end
    local function FastEq(Symbol)
        return function(a, b)
            local A, B = IsInternal(a), IsInternal(b)

            if A or B then
                local v1, v2

                if A then
                    Use(A, '__comp', true)

                    v1 = RawGet(a, 'V')
                end
                if B then
                    Use(B, '__comp', true)

                    v2 = RawGet(b, 'V')
                end
                if v1 == nil then
                    v1 = a
                end
                if v2 == nil then
                    v2 = b
                end

                local Hook = ExpressionHooks[ExpressionId]
                local HookExists, ValueOut = Hook ~= nil, nil

                if HookExists then
                    if Hook ~= 'nil' and Hook ~= 'spy' then
                        ValueOut = Hook
                    else
                        HookExists = false
                    end
                end

                local Eq

                if Symbol == '~=' then
                    Eq = v1 ~= v2
                else
                    Eq = v1 == v2
                end
                if HookExists then
                    Eq = ValueOut
                end

                local Var = AddVar('Equal', '', string.format('%s %s %s --[[expr id %s, hooked: %s, value: %s]]', tostring(A or Beautify(a)), tostring(Symbol), tostring(B or Beautify(b)), tostring(ExpressionId), tostring(HookExists), tostring(Eq)), '__eq')

                ExpressionId = ExpressionId + 1

                if HookExists then
                    return Eq
                end

                local Value = Spy(Var)

                rawset(Value, 'V', Eq)

                return Value
            end
            if Symbol == '~=' then
                return a ~= b
            else
                return a == b
            end
        end
    end
    local function Type(x, a)
        local p = IsInternal(a)

        if not p then
            return x == 'type' and type(a) or typeof(a)
        end

        local S, Type = Spy(string.format('%s(%s)', tostring(x), tostring(a))), GetType(GetActualPath(p) or p)

        if p == 'game' or p == 'workspace' or p == 'Workspace' or p == 'Game' then
            if x == 'type' then
                Type = 'userdata'
            else
                Type = 'Instance'
            end
        end

        rawset(S, 'V', Type)

        return S
    end

    local NextCalls = {}
    local Hooks = {
        hookexpr = function(id, val)
            ExpressionHooks[id] = val
        end,
        next = function(tbl, ...)
            if IsInternal(tbl) then
                if NextCalls[tbl] then
                    return NextCalls[tbl](tbl, ...)
                end

                local Func = Iter(tbl, 'next')

                NextCalls[tbl] = Func

                return Func(tbl, ...)
            else
                return next(tbl, ...)
            end
        end,
        getmetatable = function(tbl)
            if IsInternal(tbl) then
                return nil
            end

            local tp = Typeof(tbl)

            if tp ~= 'table' and tp ~= 'userdata' then
                error("invalid argument #1 to 'getmetatable', 'table' or 'userdata' expected got '" .. tp .. '')
            end

            return getmetatable(tbl)
        end,
        wait = function(a)
            return Spy(string.format('wait(%s)', tostring(a)))
        end,
        pcall = pcall,
        setfenv = function(a, b)
            if getmetatable(b) then
                return
            end

            setfenv(a, Setmetatable(b, Locked))
        end,
        islclosure = function(a)
            AddVar('IsLua', '_call', string.format('islclosure(%s)', tostring(Beautify(a))), '__call')

            if IsInternal(a) then
                if Find(ExecEnv, a) then
                    return false
                end
            end

            return DebugInfo(a, 's') ~= 'C'
        end,
        iscclosure = function(a)
            AddVar('IsC', '_call', string.format('iscclosure(%s)', tostring(Beautify(a))), '__call')

            if IsInternal(a) then
                if Find(ExecEnv, a) then
                    return true
                end
            end

            return DebugInfo(a, 's') == 'C'
        end,
        tostring = function(Str)
            if IsInternal(Str) then
                local Path = RawGet(Str, 'P')
                local Type = GetType(Path)

                return GetAddress(Path, Type)
            end

            return Tostring(Str)
        end,
        CHECKIF = function(Condition)
            local Int = IsInternal(Condition)

            if Int then
                Top.add_if_comment = true

                local v, Hook = RawGet(Condition, 'V'), ExpressionHooks[ExpressionId]
                local HookExists = Hook ~= nil

                if HookExists then
                    if Hook ~= 'nil' and Hook ~= 'spy' then
                        v = Hook
                    end
                end

                local DidRun = (v == nil or v) and '--[[ i ran ]]' or '--[[ i did not run ]]'

                Append(string.format('if %s then %s end --[[expression id %s was hooked: %s]]\n', tostring(Int), tostring(DidRun), tostring(ExpressionId), tostring(HookExists)))

                ExpressionId = ExpressionId + 1

                if v == nil then
                    return Condition
                else
                    return v
                end
            end

            return Condition
        end,
        CHECKWHILE = function(Condition)
            if Settings.max_while_count <= LoopCount then
                Append(string.format('CHECKWHILE(%s) -- this was the last call before breaking out of a big while loop.', tostring(Condition)))

                return false
            end

            LoopCount = LoopCount + 1

            local Int = IsInternal(Condition)

            if Int then
                AddVar('While', 'Condition', string.format('CHECKWHILE(%s)', tostring(Int)), '__while')
            end

            return Condition
        end,
        CHECKOR = function(a, b)
            local A, B = IsInternal(a), IsInternal(b)

            if A or B then
                local v1, v2

                if A then
                    if A == 'loadstring' then
                        return Loadstring
                    end

                    v1 = RawGet(a, 'V')
                end
                if B then
                    if B == 'loadstring' then
                        return v1 or Loadstring
                    end

                    v2 = RawGet(b, 'V')
                end
                if v1 == nil then
                    v1 = a
                end
                if v2 == nil then
                    v2 = b
                end
                if Tostring(v1 or v2) == 'getfenv()' then
                    return Locked
                end

                local Var = Spy(AddVar('comp', 'Or', string.format('(%s or %s)', tostring(A or Beautify(a)), tostring(B or Beautify(b))), '__comp'))

                rawset(Var, 'V', v1 or v2)

                return Var
            end

            return a or b
        end,
        CHECKAND = function(a, b)
            local A, B = IsInternal(a), IsInternal(b)

            if A or B then
                local v1, v2

                if A then
                    Use(A, '__comp', true)

                    v1 = RawGet(a, 'V')
                end
                if B then
                    Use(B, '__comp', true)

                    v2 = RawGet(b, 'V')
                end
                if v1 == nil then
                    v1 = a
                end
                if v2 == nil then
                    v2 = b
                end

                local Var = AddVar('Comp', 'And', string.format('%s and %s', tostring(A or Beautify(a)), tostring(B or Beautify(b))), '__comp')

                if Settings.hookOpValue == 'spy' then
                    local Return = Spy(Var)

                    rawset(Return, 'V', v1 and v2)

                    return Return
                else
                    return v1 and v2
                end
            end

            return a and b
        end,
        CHECKNOT = function(a)
            local Path = IsInternal(a)

            if Path then
                if Path == 'getconstants' then
                    return true
                end
                if Path == 'loadstring' then
                    return false
                end

                local Var, Value = GetVarID(), string.format('not %s', tostring(a))

                Append(string.format('local %s = %s;', tostring(Var), tostring(Value)))
                Define(Var, Value, '__comp')

                if Settings.hookOpValue == 'spy' then
                    local Return, V = Spy(Var), RawGet(a, 'V')

                    if V == nil then
                        V = true
                    end

                    rawset(Return, 'V', not V)

                    return Return
                end
            end

            return not a
        end,
        __NEQ = FastEq('~='),
        __EQ = FastEq('=='),
        CHECKLEN = function(a)
            local A, Len = IsInternal(a), #a

            if A then
                Use(A, '__len', true)

                local Var = Spy(AddVar('Len', 'len', string.format('#%s', tostring(A)), '__len'))

                rawset(Var, 'V', Len)

                return Var
            end

            return Len
        end,
        COMPL = FastComp('<'),
        COMPG = FastComp('>'),
        COMPLE = FastComp('<='),
        COMPGE = FastComp('>='),
        getgc = function(dotbls, ...)
            assert(select('#', ...) == 0, "bad arguments to 'getgc' (only one argument expected)")
            if Type(dotbls) ~= 'boolean' and Type(dotbls) ~= "nil" then
                error("bad argument #1 to 'getgc' (boolean or nil expected got " .. Typeof(dotbls) .. ')', 2)
            end
            return Spy('getgc(' .. (dotbls == nil and "false" or tostring(dotbls)) .. ')')
        end,
        getreg = function(...)
            assert(select('#', ...) == 0, "bad arguments to 'getreg' (no arguments expected)")
            return Spy('getreg()')
        end,
        getregistry = function(...)
            assert(select('#', ...) == 0, "bad arguments to 'getregistry' (no arguments expected)")
            return Spy('getregistry()')
        end, getupvalues = function(func,...)
            assert(select('#', ...) == 0, "bad arguments to 'getupvalues' (only one argument expected)")
            if Type(func) ~= 'function' and Type(func) ~= 'number' then
                error("bad argument #1 to 'getupvalues' (function or number expected got " .. Typeof(func) .. ')', 2)
            end
            return Spy('-- a functions upvalues were accessed here, ' .. DebugInfo(Type(func) == "number" and func + 1 or func, "slnaf"))
        end,
        getupvalue = function(func, index,...)
            assert(select('#', ...) == 0, "bad arguments to 'getupvalue' (exactly two expected)")
            if Type(func) ~= 'function' and Type(func) ~= 'number' then
                error("bad argument #1 to 'getupvalue' (function or number expected got " .. Typeof(func) .. ')', 2)
            end
            return Spy('-- a function upvalue was accessed here, ' .. DebugInfo(Type(func) == "number" and func + 1 or func, "slnaf") .. " " .. index)
        end,
        setupvalue = function(func, index, newval, ...)
            assert(select('#', ...) == 0, "bad arguments to 'setupvalue' (exactly three expected)")
            if Type(func) ~= 'function' and Type(func) ~= 'number' then
                error("bad argument #1 to 'setupvalue' (function or number expected got " .. Typeof(func) .. ')', 2)
            end
            return Spy('-- a function upvalue was set here, ' .. DebugInfo(Type(func) == "number" and func + 1 or func, "slnaf") .. " " .. index)
        end,
        getconstants = function(func, ...)
            assert(select('#', ...) == 0, "bad arguments to 'getconstants' (only one argument expected)")
            if Type(func) ~= 'function' and Type(func) ~= 'number' then
                error("bad argument #1 to 'getconstants' (function or number expected got " .. Typeof(func) .. ')', 2)
            end
            return Spy('-- a functions constants were accessed here, ' .. DebugInfo(Type(func) == "number" and func + 1 or func, "slnaf"))
        end,
        getconstant = function(func, constIdx, ...)
            assert(select('#', ...) == 0, "bad arguments to 'getconstant' (only two arguments expected)")
            if Type(func) ~= 'function' and Type(func) ~= 'number' then
                error("bad argument #1 to 'getconstant' (function or number expected got " .. Typeof(func) .. ')', 2)
            end
            return Spy('-- a function constant was accessed here, ' .. DebugInfo(Type(func) == "number" and func + 1 or func, "slnaf") .. " " .. constIdx)
        end
    }

    Hooks.type, Hooks.typeof = function(...)
        return Type('type', ...)
    end, function(...)
        return Type('typeof', ...)
    end

    local function Deglobal(Text)
        for _, Name in next, ExecEnv do
            if Text == Name then
                return Text .. GetVar(Text)
            end
        end

        return Text
    end
    local function HookLib(Lib, Extra)
        local l, r = getfenv()[Lib], {P = Lib}

        for i, v in next, l do
            r[i] = SafeWrap(v, Index(i, Lib), true)
        end
        for i, v in next, Extra or {}do
            r[i] = v
        end

        local Meta = Setmetatable(r, {
            __tostring = function()
                return Lib
            end,
            __metatable = 'This metatable is locked.',
            __iter = Iter,
        })

        Internal[Meta] = Lib

        return Meta
    end

    Hooks.string, Hooks.table, Hooks.math = HookLib('string'), table, HookLib('math')
    Hooks.coroutine = HookLib('coroutine', {
        resume = function(co, ...)
            if type(co) ~= 'thread' then
                error("bad argument #1 to 'resume' (thread expected got " .. type(co) .. ')', 2)
            end

            local Co, Args, Tuple = Spy(Index('resume', 'coroutine')), Pack(...), {}

            for i = 1, Args.n do
                Insert(Tuple, Beautify(Args[i], CurrentIndent + 1))
            end

            Append(string.format('local success, result = %s(%s, %s)', tostring(Co), tostring(Beautify(co)), tostring(Concat(Tuple, ', '))))

            return unpack(Co)
        end,
    })
    Hooks.debug = Setmetatable({
        getinfo = function(thread, ...)
            assert(select('#', ...) == 0, "bad arguments to 'getinfo' (only one argument expected)")
            if typeof(thread) ~= 'function' and typeof(thread) ~= 'number' then
                return error("bad argument #1 to 'getinfo' (function, thread, or number expected got " .. typeof(thread) .. ')', 2)
            end
            if typeof(thread) == "thread" then
                thread = DebugInfo(thread, 1, "f")
            end
            local source, name, line, numparams, isvrg = DebugInfo(thread, 'slna')
            Spy("--[[debug.getinfo called with" .. tostring(source) .. ", " .. tostring(name) .. ", " .. tostring(line) .. ", " .. tostring(numparams) .. ", " .. tostring(isvrg) .. "]]")

            return Setmetatable({
                line = line,
                numparams = numparams,
                is_vararg = isvrg and 1 or 0,
                what = DebugInfo(thread, 's') == '[C]' and 'C' or 'Lua',
                source = DebugInfo(2, 's'):gsub("string \"luau%.load%(.-%)\"", TraceId):gsub("luau.load", TraceId),
                short_src = DebugInfo(2, 's'):gsub("string \"luau%.load%(.-%)\"", TraceId):gsub("luau.load", TraceId),
            }, {
                __index = function(_, Key)
                    Append(string.format("-- The script indexed debug.getinfo(...) with key '%s'.", tostring(Key)))
                end,
            })
        end,
        traceback = function(a, ...)
            assert(select('#', ...) == 0, "bad arguments to 'traceback' (only one argument expected)")
            assert(not a or Typeof(a) == 'string', "invalid argument #1 to 'traceback' (string expected got " .. Typeof(a) .. ')')

            local trace = debug.traceback(a)
            local lines, out = Split(trace, '\n'), {}

            for _, v in next, lines do
                if not Match(v, '%[string ".*hi"%]') then
                    v = Gsub(v, 'string "luau%.load%(.-%)"', TraceId)

                    Insert(out, v)
                end
            end

            return Concat(out, '\n')
        end,
        info = function(f, a, opt, ...)
            assert(select('#', ...) == 0, "bad arguments to 'info' (at most three arguments expected)")
            if Typeof(f) ~= "thread" then
                opt = a
            end
            assert(Typeof(f) == 'function' or Typeof(f) == 'number', "bad argument #1 to 'info' (function or level expected got " .. Typeof(f) .. ')')
            assert(Typeof(opt) == 'string', "bad argument #2 to 'info' (string expected got " .. Typeof(opt) .. ')')
            return Spy('-- debug.info was called here')
        end,
        getregistry = function(...)
            assert(select('#', ...) == 0, "bad arguments to 'getregistry' (no arguments expected)")
            return Spy('debug.getregistry()')
        end, getupvalues = function(func, ...)
            assert(select('#', ...) == 0, "bad arguments to 'getupvalues' (only one argument expected)")
            if Type(func) ~= 'function' and Type(func) ~= 'number' then
                error("bad argument #1 to 'getupvalues' (function or number expected got " .. Typeof(func) .. ')', 2)
            end
            return Spy('-- a functions upvalues were accessed here, ' .. DebugInfo(Type(func) == "number" and func + 1 or func, "slnaf"))
        end,
        getupvalue = function(func, index, ...)
            assert(select('#', ...) == 0, "bad arguments to 'getupvalue' (only two arguments expected)")
            if Type(func) ~= 'function' and Type(func) ~= 'number' then
                error("bad argument #1 to 'getupvalue' (function or number expected got " .. Typeof(func) .. ')', 2)
            end
            return Spy('-- a function upvalue was accessed here, ' .. DebugInfo(Type(func) == "number" and func + 1 or func, "slnaf") .. " " .. index)
        end,
        setupvalue = function(func, index, newval, ...)
            assert(select('#', ...) == 0, "bad arguments to 'setupvalue' (only three arguments expected)")
            if Type(func) ~= 'function' and Type(func) ~= 'number' then
                error("bad argument #1 to 'setupvalue' (function or number expected got " .. Typeof(func) .. ')', 2)
            end
            return Spy('-- a function upvalue was set here, ' .. DebugInfo(Type(func) == "number" and func + 1 or func, "slnaf") .. " " .. index)
        end,
        getconstants = function(func, ...)
            assert(select('#', ...) == 0, "bad arguments to 'getconstants' (only one argument expected)")
            if Type(func) ~= 'function' and Type(func) ~= 'number' then
                error("bad argument #1 to 'getconstants' (function or number expected got " .. Typeof(func) .. ')', 2)
            end
            return Spy('-- a functions constants were accessed here, ' .. DebugInfo(Type(func) == "number" and func + 1 or func, "slnaf"))
        end,
        getconstant = function(func, constIdx, ...)
            assert(select('#', ...) == 0, "bad arguments to 'getconstant' (only two arguments expected)")
            if Type(func) ~= 'function' and Type(func) ~= 'number' then
                error("bad argument #1 to 'getconstant' (function or number expected got " .. Typeof(func) .. ')', 2)
            end
            return Spy('-- a function constant was accessed here, ' .. DebugInfo(Type(func) == "number" and func + 1 or func, "slnaf") .. " " .. constIdx)
        end,
        setmetatable = Spy('debug.setmetatable'),
        P = 'debug',
    }, {
        __index = function(_, Key)
            return debug[Key] and Spy(Index(Key, 'debug')) or nil
        end,
        __tostring = function()
            return 'debug'
        end,
        __newindex = function(_, k, v)
            if k == 'P' then
                return
            end

            rawset(_, k, v)
        end,
        __iter = Iter,
    })
    Internal[Hooks.debug] = 'debug'

    local TrueEnv = getfenv(Main)

    TrueEnv.bit = bit32
    TrueEnv.ypcall = pcall

    local MoonSec = IsFile and Source:find('This file was protected with MoonSec V3')
    local MoonSecAntiTamper, MoonSecCP, Pristine, Tasks, EnvValues, IterFuncs, Funcs, WrapFuncs, Tables, Env = MoonSec and Source:find('_ENV'), MoonSec and Source:find('//'), nil, 0, {
        _ENV = {},
        bit = {bit32},
    }, {
        'pairs',
        'ipairs',
    }, {
        'newproxy',
        'select',
        'setmetatable',
        'assert',
        'rawget',
        'rawset',
        'xpcall',
        'unpack',
        'ypcall',
        'error',
        'spawn',
        'getmetatable',
    }, {
        'tonumber',
        'collectgarbage',
        'tostring',
        'pcall',
    }, {
        'bit',
        'bit32',
        'table',
        'coroutine',
    }, {}

    for i, v in Next, Hooks do
        Env[i] = v
    end
    for _, i in Next, WrapFuncs do
        Env[i] = SafeWrap(TrueEnv[i], i)
    end
    for _, i in Next, Funcs do
        Env[i] = TrueEnv[i]
    end
    for _, i in Next, Tables do
        Env[i] = TrueEnv[i]
    end

    local Task = Setmetatable({}, {
        __index = function(_, Key)
            local Actual = task[Key]

            return Actual and (Pristine and function(...)
                Tasks = Tasks + 1

                local Args, Input = Pack(...), {}

                for i = 1, Args.n do
                    local Arg = Args[i]

                    if Typeof(Arg) == 'function' then
                        Arg = setfenv(Arg, Locked)
                    end

                    Input[i] = Arg
                end

                return Pristine and Tasks <= 5 and Actual(Unpack(Input)) or Spy(AddVar('scheduled', '', string.format('%s(%s)', tostring(Index(Key, 'task')), tostring(BeautifyTuple(Unpack(Input)))), '__call'))
            end or function(...)
                local Indexed = Index(Key, 'task')

                OpCount = OpCount + 1

                OpCountCheck()

                return Spy(AddVar('', '', string.format('%s(%s)', tostring(Indexed), tostring(BeautifyTuple(...))), '__call'))
            end) or nil
        end,
    })

    Internal[Task] = 'task'
    Env.task = Task

    local Function, SetfenvResult = IsFile and loadstring(Source) or Source, nil
    local ParamCount, Extra = DebugInfo(Function, 'a')
    local Params = {
        SpyParams(ParamCount + 50),
    }

    if Extra then
        Insert(Params, Spy('...', {Param = true}))
    end
    if MoonSecAntiTamper then
        print('MoonSec anti tamper enabled')
    end
    if MoonSecCP then
        print('MoonSec constant protection enabled')
    end
    if MoonSecAntiTamper or MoonSecCP then
        print('Script uses MoonSec AntiTamper / Constant Protection')

        local _core = {
            tonumber = tonumber,
            select = select,
            unpack = unpack,
            tostring = tostring,
            pcall = pcall,
            --setmetatable = setmetatable,
            setfenv = setfenv, -- hmm...
            rawget = rawget,
            assert = assert,
            os = {time = os.time, clock = os.clock, date = os.date, difftime = os.difftime},
            type = type,
            bit32 = bit32,
        }

        for HookKey, Hook in next, Hooks do
            _core[HookKey] = _core[HookKey] or Hook
        end

        _core.wait = function()
            return 1
        end

        local loads = 0

        Locked = setmetatable(_core, {
            __index = function(_, Key)
                if Key == 'getconstants' or Key == '_ENV' then
                    return
                end
                if Key == 'getfenv' then
                    return function()
                        return Locked
                    end
                end
                if Key == 'loadstring' then
                    return Setmetatable({}, {
                        __call = function(_, Source, Chunk)
                            loads = loads + 1

                            if Typeof(Source) == 'table' and not IsInternal(Source) then
                                error('no load')
                            end

                            return function(...)
                                if Typeof(Source) == 'string' then
                                    if loads <= 4 then
                                        if not Settings.raw then
                                            Source = HookOpHandler(Source)
                                        end

                                        return setfenv(loadstring(Source, Chunk), Locked)(...)
                                    end

                                    Append(Beautify(loadstring(Source)))
                                else
                                    local Var = GetVarID()

                                    Append(string.format('local %s = loadstring(%s)(%s)', tostring(Var), tostring(Beautify(Source)), tostring(BeautifyTuple(...))))

                                    return Spy(Var)
                                end
                            end
                        end,
                    })
                end
                if Find(IterFuncs, Key) then
                    return function(a)
                        return Iter(a, Key)
                    end
                end

                local Indexed = Index(Key)

                if Settings.env_index then
                    Append(string.format('local _ = %s', tostring(Indexed)))
                end

                local IsSafe = Find(ExecEnv, Key)

                if IsSafe and (#Key ~= 32 and (#Key ~= 13) and #Key ~= 17) then
                    print('Spy', Indexed)

                    return Spy(Indexed)
                end

                return nil
            end,
            __tostring = function()
                return 'getfenv()'
            end,
            __newindex = function(_, k, v)
                if k == 'P' then
                    return
                end

                rawset(_, k, v)
            end,
            __metatable = nil,
        })

        rawset(Locked, 'P', 'getfenv()')
        rawset(Locked, 'V', Locked)

        Internal[Locked] = 'getfenv()'
        getfenv = newcclosure(function()
            return Locked
        end)
    else
        Locked = Setmetatable(Env, {
            __index = function(_, Key)
                OpCount = OpCount + 1

                OpCountCheck()

                if Key == '_ENV' then
                    return
                end
                if Key == 'getfenv' then
                    return function()
                        return Locked
                    end
                end
                if Key == 'loadstring' then
                    return Loadstring
                end
                if Find(IterFuncs, Key) then
                    return NewCClosure(function(Table)
                        if IsInternal(Table) then
                            return Iter(Table, Key)
                        else
                            return TrueEnv[Key](Table)
                        end
                    end)
                end

                local a, Indexed, IsExec = EnvValues[Key] or (Pristine and {
                    TrueEnv[Key],
                } or nil), Index(Key), Find(ExecEnv, Key)

                if a or (Find({14, 13, 12}, #Key) and not IsExec) then
                    return (a or {})[1]
                end
                if Settings.env_index then
                    Append(string.format('local _ = %s', tostring(Indexed)))
                end
                if Settings.spy_exec_only then
                    if not IsExec then
                        return (a or {})[1]
                    end
                    if Pristine then
                        if GetType(Key) == 'function' then
                            return function(...)
                                if Typeof(...) == 'function' then
                                    return a[1](...)
                                end

                                return Spy(AddVar('', '', string.format('%s(%s)', tostring(Key), tostring(BeautifyTuple(...))), '__call'))
                            end
                        end
                    end

                    return Spy(Indexed)
                end

                return Spy(Indexed)
            end,
            __newindex = function(_, Key, Value)
                EnvValues[Key] = {Value}
                OpCount = OpCount + 1

                if Settings.max_ops <= OpCount then
                    print('Too much')
                    error('Too many operations.')
                end
                if Settings.spy_exec_only then
                    return
                end

                local IsFunc, Indexed = Typeof(Value) == 'function', Index(Key)

                if IsFunc and not Settings.spy_exec_only then
                    Output[#Output + 1] = Beautify(Value, CurrentIndent + 1, {FuncName = Key})

                    return
                elseif not IsFunc then
                    Append(string.format('%s = %s', tostring(Indexed), tostring(Beautify(Value, CurrentIndent + 1))))
                end
            end,
            __tostring = function()
                return 'getfenv()'
            end,
            __metatable = nil,
            __iter = Iter,
        })

        rawset(Locked, 'P', 'getfenv()')
        rawset(Locked, 'V', Locked)

        Internal[Locked] = 'getfenv()'
    end

    SetfenvResult = table.pack(pcall(setfenv(Function, Locked), Unpack(Params)))

    local ReturnValue = ''

    if not SetfenvResult[1] then
        ReturnValue = string.format('error(%s)', tostring(Beautify(SetfenvResult[2])))
    else
        if #SetfenvResult > 1 then
            ReturnValue = 'return '

            for i = 2, SetfenvResult.n do
                ReturnValue = ReturnValue .. Beautify(SetfenvResult[i], CurrentIndent + 1) .. ', '
            end

            ReturnValue = Sub(ReturnValue, 1, -3)
        end
    end
    if Original then
        Insert(Output, ReturnValue)
    end

    local Out, Replace = '', {}

    local function CaseInsensitive(A)
        local Out = ''

        for _, Letter in Next, Split(A, '')do
            Out = Out .. string.format('([%s%s])', tostring(Upper(Letter)), tostring(Lower(Letter)))
        end

        return Out
    end
    local function DecodeArgs(Str)
        local Args = {}

        for _, v in next, Split(Str, ', ')do
            local Number, Value = (Tonumber(v))

            if Sub(v, 1, 1) == '"' then
                Value = Sub(v, 2, -2)
            elseif Number then
                Value = Number
            elseif v == 'true' then
                Value = true
            elseif v == 'false' then
                Value = false
            else
                Value = v
            end

            Insert(Args, Value)
        end

        return Args
    end
    local function GetName(Var, Value, Side2, Old)
        local VarId, Name, IsNamecall, Comp = Match(Var, '%d+') or '', nil, string.find(Side2, ':') and Value.Tag == '__call', {
            ['<'] = 'is_less',
            ['>'] = 'is_greater',
            ['<='] = 'less_equal',
            ['>='] = 'greater_equal',
        }

        if IsNamecall then
            local Calls, Args = Split(Side2, ':'), DecodeArgs(Match(Side2, '%((.-)%)'))

            Name = Split(Calls[#Calls], '(')[1]

            if Find({
                'FindFirstChild',
                'WaitForChild',
                'FindFirstChildOfClass',
                'GetService',
            }, Name) then
                Name = Args[1] .. VarId
            end

            Name = Gsub(Name, CaseInsensitive('Get'), '')
            Name = Gsub(Name, CaseInsensitive('Make'), '')
            Name = Gsub(Name, CaseInsensitive('Create'), '')
            Name = Gsub(Name, CaseInsensitive('Decode'), '%1ecoded')
            Name = Gsub(Name, CaseInsensitive('Encode'), '%1ncoded')
        elseif Value.Tag == '__index' then
            local Indexes = SplitIDX(Value.Value)

            Name = Indexes[#Indexes]
        elseif Value.Tag == '__comp' then
            local Symbol, Keyword = Match(Side2, '[<>]=?'), Match(Side2, '%w+')

            Name = Comp[Symbol or Keyword] or 'unknown'
        elseif Value.Tag == '__len' then
            Name = 'len'
        elseif Value.Tag == '__eq' then
            local Type = Match(Value.Value, '[~=]=')

            if Type == '~=' then
                Name = 'not_equal'
            else
                Name = 'is_equal'
            end
        elseif Value.Tag == '__call' then
            local Out = Values[Var].Value
            local Old, Changed = Out, true

            while Changed do
                for Var2, Value in next, Values do
                    local __DARKLUA_CONTINUE_40 = false

                    repeat
                        local v = Value.Value

                        if not v or Value.Usage > 1 or Var2 == Var then
                            __DARKLUA_CONTINUE_40 = true

                            break
                        end

                        Out = Gsub(Out, Var2 .. '(%D)', RE_Safe(v) .. '%1')
                        __DARKLUA_CONTINUE_40 = true
                    until true

                    if not __DARKLUA_CONTINUE_40 then
                        break
                    end
                end

                Changed, Old = Out ~= Old, Out
            end

            local Path = Split(Out, '(')[1]
            local Indexes = Split(Path, '.')
            local First, Args = Indexes[1], DecodeArgs(Match(Side2, '%((.-)%)'))

            if Path == 'Instance.new' then
                Name = Args[1]
            elseif First == 'Vector3' or First == 'Vector2' or First == 'CFrame' or First == 'Path2DControlPoint' or First == "Vector2int16" or First == "Vector3int16" then
                local n = Sub(First, 1, First == 'CFrame' and 3 or 2) .. Sub(First, #First) .. '_'

                Name = n .. Indexes[2]
            else
                Name = Gsub(Path, '%W', '') .. '_call'
            end
        end
        if Name then
            Name = Deglobal(Name .. GetVar(Name))
        end
        if not Name or Match(Name, '[^A-Za-z0-9_]') or Name == '' or Tonumber(Sub(Name, 1, 1)) then
            Name = Var
        else
            Replace[Var] = Name
        end

        return Name and string.format('local %s =%s', tostring(Name), tostring(Side2)) or Old
    end

    local CachedSafe = {}

    local function GetSafe(val)
        if not CachedSafe[val] then
            CachedSafe[val] = RE_Safe(val)
        end

        return CachedSafe[val]
    end
    local function HandleSplit(Separated)
        local Side1, Side2 = Separated[1], Concat(Move(Separated, 2, #Separated, 1, {}), '=')
        local IsLocal = Sub(Side1, 1, 5) == 'local'
        local Var = IsLocal and Sub(Side1, 7, -2)
        local Value, Old = Values[Var], string.format('%s=%s', tostring(Side1), tostring(Side2))

        if not Var or not Value or not Value.Value then
            return Old
        end
        if Value.Usage == 1 or Value.Usage < 0 then
            local Val = Value.Value

            for var, val in next, Values do
                local __DARKLUA_CONTINUE_41 = false

                repeat
                    local valVal = val.Value

                    if not valVal or val.Usage > 1 then
                        __DARKLUA_CONTINUE_41 = true

                        break
                    end

                    Val = Gsub(Val, var .. '(%D)', GetSafe(valVal) .. '%1')
                    __DARKLUA_CONTINUE_41 = true
                until true

                if not __DARKLUA_CONTINUE_41 then
                    break
                end
            end

            Replace[Var] = Val
        elseif Value.Usage == 0 then
            return Value.Tag == '__call' and Value.Value or string.format('local _ =%s', tostring(Side2))
        else
            if not Settings.varRenamer then
                return Old
            end

            return GetName(Var, Value, Side2, Old)
        end
    end

    local Minify, NewOut = Settings.minifier, Output

    if Minify then
        for _, v in next, NewOut do
            local __DARKLUA_CONTINUE_42 = false

            repeat
                local Stripped = Strip(v)
                local Separated, Spaces = Split(Stripped, '='), Match(v, '^%s+') or ''

                if #Separated > 1 then
                    local Handled = HandleSplit(Separated)

                    if not Handled then
                        __DARKLUA_CONTINUE_42 = true

                        break
                    end

                    v = Spaces .. Handled
                end

                Out = Out .. v .. '\n'
                __DARKLUA_CONTINUE_42 = true
            until true

            if not __DARKLUA_CONTINUE_42 then
                break
            end
        end

        local Old, Changed = Out, true

        while Changed do
            Out = Gsub(Out, 'if not not ', 'if ')

            for Var, Value in next, Replace do
                Out = Gsub(Out, Var .. '(%D)', RE_Safe(Value) .. '%1')
            end

            Changed, Old = Out ~= Old, Out
        end
    else
        Out = Concat(NewOut, '\n')
    end

    Out = Gsub(Out, '%s*\n%s*\n', '\n')

    return Strip(Out, true), ReturnValue
end

function HookOpHandler(code)
    if Settings.hookOp then
        local Path = string.format('25ms/hook_op/file_cache/hook_op_%s.lua', tostring(GenerateId(32)))

        fs.writeStringToFile(Path, code)
        Process.run({
            'lute',
            'oldhookop.luau',
            Path,
            Path,
        })

        local Content = fs.readFileToString(Path)

        fs.remove(Path)

        return Content
    end

    return code
end

local function Decode(File, outf)
    local Source = fs.readFileToString(File)

    Settings.outfile = Settings.outfile or 'out2.lua'

    local Start, Success, Code = Clock(), pcall(Main, Settings.raw and Source or HookOpHandler(Source), nil, nil, true)
    local End = Clock() - Start

    print('Took', End, 'seconds to process.', Success)

    if type(Code) == 'userdata' or not Success then
        Code = string.format('error(%s) --internal error', tostring(Beautify(Code)))
    end

    local Metadata, Out = {
        time = string.format('%s @ %s', tostring(os.date('%d/%m/%Y')), tostring(os.date('%H:%M:%S'))),
        time_taken = End,
    }, '--[[\n\tthis file was dumped using unveilr v1.0.6\n'

    for k, v in next, Metadata do
        Out = Out .. string.format('\t%s = %s;\n', tostring(k), tostring(v))
    end

    Out = Out .. ']]\n\n'

    if Top.add_if_comment then
        Out = Out .. '-- When you see an if statement, the only correct thing you see is the first argument, the code after is ALL invalid. (theres an end right after)\n'
    end

    Out = Out .. Code

    fs.writeStringToFile(outf, Out)
end
assert(Process.args[2], 'no input file provided')
local set = Process.args[4]
if set then
    set = FileSystem.read(set)
    for i,v in next, json.deserialize(set) do
        Settings[i] = v
    end
end
return Decode(Process.args[2], Process.args[3] or 'out.lua')
