" Syntax folding for C#
syntax region block start="{" end="}" transparent fold
syntax region csComment start="/\*" end="\*/" fold contains=@csCommentHook,csTodo,@Spell
syntax match csXmlComment "\v(^\s*\/\/.*\n)+" fold contains=csXmlCommentLeader,@csXml,@Spell
