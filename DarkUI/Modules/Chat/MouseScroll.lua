local E, C, L = select(2, ...):unpack()

------------------------------------------------------------------------
-- Mouse Scroll
------------------------------------------------------------------------

local module = E:Module("Chat"):Sub("MouseScroll")

function module:OnInit()
    local ScrollLines = 1

    function FloatingChatFrame_OnMouseScroll(self, delta)
        if delta < 0 then
            if IsShiftKeyDown() then
                self:ScrollToBottom()
            else
                for i = 1, ScrollLines do
                    self:ScrollDown()
                end
            end
        elseif delta > 0 then
            if IsShiftKeyDown() then
                self:ScrollToTop()
            else
                for i = 1, ScrollLines do
                    self:ScrollUp()
                end
            end
        end
    end
end
