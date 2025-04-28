-- 把 Core 全挂全局上

_G.Selector = require('./ControlNodes/Selector')
_G.Sequence = require('./ControlNodes/Sequence')

_G.Cooldown = require('./DecoratorNodes/Cooldown')
_G.Failer = require('./DecoratorNodes/Failer')
_G.Inverter = require('./DecoratorNodes/Inverter')
_G.Repeat = require('./DecoratorNodes/Repeat')
_G.Retry = require('./DecoratorNodes/Retry')
_G.Succeeder = require('./DecoratorNodes/Succeeder')
_G.Task = require('./DecoratorNodes/Task')
_G.Timeout = require('./DecoratorNodes/Timeout')

_G.ActionNode = require('./ExecutionNodes/ActionNode')
_G.ConditionNode = require('./ExecutionNodes/ConditionNode')

_G.BehaviorTree = require('./BehaviorTree')