# ragnarok homuculus ai

最好给重命名一下哦
```git clone https://github.com/ranmeizi/ro-homu-ai.git AI_sakray```

## test

去 ../ 目录

测试读取json
``lua AI_sakray/USER_AI/test/readjson.lua``

测试 Memory
``lua AI_sakray/USER_AI/test/memory.lua``

测试 Try
``lua AI_sakray/USER_AI/test/try.lua``

测试 AI loop
``lua AI_sakray/USER_AI/test/loop.lua``

```lua AI_sakray/USER_AI/test/test_behavior_tree.lua```

### 行为树设计

#### Task 跨Tick的任务

全局只有唯一一个跨Tick的任务，因为生命体也不能同时干2件事，那该乱了。
通过 blackboard 记录这个任务的信息，第二次执行通过 Condition 检查是否有当前任务信息，如果返回不是running，才会清除这个任务，走到下个节点，也就是说 任务模块是优先级相当高的一个节点。

#### Core下实现了基础节点以及装饰节点

装饰节点没测过，用的时候再改吧

### 命令设计

基本只有 alt+t 和 alt+左键 可以发命令，那么就用这些组合设计一套命令系统。

```mermaid
flowchart TD
    cmd_n1[Selector 命令系统]
    cmd_cond{是否按下 alt+t?}
    cmd_cond_move{是否下达 Move 命令 ==1?}
    cmd_cond_attack{是否下达 Attack 命令 ==3?}
    cmd_cond_skill{是否下达 Skill 命令 ==7?}
    cmd_cond_y[Selector 等候组合命令]
    cmd_cond_n[Failer]
    cmd_timeout_1[Timeout 接下来 X tick内]
    cmd_timeout_fail[Timeout 超时 清空队列]
    cmd_seq_1[Selector Options]
    cmd_cond_opt{是否按下 alt+t?}
    cmd_cond_opt1{是下达move位置1 TOP_LEFT?}
    cmd_cond_opt2{是下达move位置2 TOP?}
    cmd_cond_opt3{是下达move位置3 TOP_RIGHT?}
    cmd_cond_opt4{是下达move位置4 RIGHT?}
    cmd_cond_opt5{是下达move位置5 BOTTOM_RIGHT?}
    cmd_cond_opt6{是下达move位置6 BOTTOM?}
    cmd_cond_opt7{是下达move位置7 BOTTOM_LEFT?}
    cmd_cond_opt8{是下达move位置8 LEFT?}
    opt[放弃任务]
    opt_todo[预留]
    attack[中断任务#设置 Kill Task]
    skill[中断任务#Action 试着放技能]
    move[中断任务#设置 MoveTo Task]

    cmd_n1 --> cmd_cond
    cmd_n1 --> cmd_cond_move --> move
    cmd_n1 --> cmd_cond_attack --> attack
    cmd_n1 --> cmd_cond_skill --> skill
    cmd_cond -->|Yes| cmd_cond_y
    cmd_cond -->|No| cmd_cond_n
    cmd_cond_y --> cmd_timeout_1
    cmd_cond_y --> cmd_timeout_fail
    cmd_timeout_1 --> cmd_seq_1
    cmd_seq_1 --> cmd_cond_opt
    cmd_seq_1 --> cmd_cond_opt1
    cmd_seq_1 --> cmd_cond_opt2
    cmd_seq_1 --> cmd_cond_opt3
    cmd_seq_1 --> cmd_cond_opt4
    cmd_seq_1 --> cmd_cond_opt5
    cmd_seq_1 --> cmd_cond_opt6
    cmd_seq_1 --> cmd_cond_opt7
    cmd_seq_1 --> cmd_cond_opt8
    cmd_cond_opt --> |Yes| opt
    cmd_cond_opt1 --> |Yes| opt_todo
    cmd_cond_opt2 --> |Yes| opt_todo
    cmd_cond_opt3 --> |Yes| opt_todo
    cmd_cond_opt4 --> |Yes| opt_todo
    cmd_cond_opt5 --> |Yes| opt_todo
    cmd_cond_opt6 --> |Yes| opt_todo
    cmd_cond_opt7 --> |Yes| opt_todo
    cmd_cond_opt8 --> |Yes| opt_todo
```

### 基本逻辑

- Test 行为树
测试用的 瞎写
```mermaid
flowchart TD
    Root[Sequence root] --> N1[Action ResCommand 接收命令]
    Root --> N2[TaskModule]
    N2 --> N3[Sequence]
    subgraph task[任务模块 这个可能用代码实现，不走节点]
        N3 --> Task_cond{Condition 有无任务}
        N3 --> Task[任务执行]
        Task --> Task_n1[Selector]
        Task_n1 --> Task_cond1{Condition 是FilirFarm?}
        Task_n1 --> Task_cond2{Condition 是Kiting?}
        Task_cond1 --> Task_n2[Selector] 
        Task_n2 --> Task_cond3{Condition 是filir?}
        Task_cond3 --> Task_Farm_filir
        subgraph filir_farm[飞里乐练级]
            Task_Farm_filir[Sequence] --> tff_n1[Action FindBestTarget 寻敌]
            Task_Farm_filir-->tff_cond1{Condition 有target?}
            Task_Farm_filir-->tff_n3[Action Kill 杀敌]
        end
        Task_n2 --> Task_cond4{Condition 是其他?}
        Task_cond2 --> Task_none[我只是写个例子，这个很久以后开发]
    end
    Root -->N4[Action Enviroment环境监测]
   
```

命令模块
```mermaid
flowchart TD
    Comd[命令模块]
```

任务模块
```mermaid
flowchart TD
    Comd[任务模块]
```

- Filir 行为树


Farm 逻辑

寻敌 -> kill target

kill target 逻辑

moveTo