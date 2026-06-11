local E, C, L = select(2, ...):unpack()

------------------------------------------------------------------------
-- Faster Movie Skip
------------------------------------------------------------------------

local module = E:Module("Misc"):Sub("FasterMovieSkip")

local cfg = C.misc

local function skipOnKeyDown(self, key)
    if key == "ESCAPE" then
        if self:IsShown() and self.closeDialog and self.closeDialog.confirmButton then
            self.closeDialog:Hide()
        end
    end
end

local function skipOnKeyUp(self, key)
    if key == "SPACE" or key == "ESCAPE" or key == "ENTER" then
        if self:IsShown() and self.closeDialog and self.closeDialog.confirmButton then
            self.closeDialog.confirmButton:Click()
        end
    end
end

function module:OnInit()
    if not cfg.faster_movie_skip then return end

    MovieFrame.closeDialog = MovieFrame.CloseDialog
    MovieFrame.closeDialog.confirmButton = MovieFrame.CloseDialog.ConfirmButton
    CinematicFrame.closeDialog.confirmButton = CinematicFrameCloseDialogConfirmButton

    MovieFrame:HookScript("OnKeyDown", skipOnKeyDown)
    MovieFrame:HookScript("OnKeyUp", skipOnKeyUp)
    CinematicFrame:HookScript("OnKeyDown", skipOnKeyDown)
    CinematicFrame:HookScript("OnKeyUp", skipOnKeyUp)
end
