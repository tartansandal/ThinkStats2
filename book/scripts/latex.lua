-- Replace "{\tt foobar }" in Latex with inline code
return {
    {
        Str = function (s)
            if s.text == '{\tt FOOBAR}' then
                return pandoc.Code{'FOOBAR'}
            else
                return s
            end
        end,
    }
}
