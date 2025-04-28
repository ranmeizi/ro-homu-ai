local IDEL = Sequence:new({
    -- 获取消息
    ResCommand,
    -- 判断
    Succeeder:new(
        Selector:new({
            Sequence:new({
                -- 判断第一位是不是 FOLLOW_CMD,如果是，进入后续 x tick 的第二 cmd 的判断
                ConditionNode:new(createCmdCondition(1, FOLLOW_CMD)),
                -- Timeout节点
            }),
            Sequence:new({
                -- 判断第一位是不是 MOVE_CMD
                ConditionNode:new(createCmdCondition(1, MOVE_CMD)),
                -- 插队一个 MoveTo Task
                ActionNode:new(tryJumpTask(createMoveToTask))
            }),

        })
    )
})

return IDEL