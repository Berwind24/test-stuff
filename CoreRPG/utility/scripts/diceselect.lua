-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

DICE_SCALE_MIN = 80;
DICE_SCALE_MAX = 120;

function onInit()
	DiceManager.populateDiceSelectWindow(self);
	DiceSkinManager.populateDiceSelectWindow(self);
	self.updateDiceDesktopDisplay();
	self.updateDiceSkinDisplay();
end

--
--	UI - SIZE CHANGE
--

function updateDiceDesktopDisplay()
	local nScale = Interface.getDiceRelativeScale();
	button_desktop_scaledown.setVisible(nScale > DICE_SCALE_MIN);
	button_desktop_scaleup.setVisible(nScale < DICE_SCALE_MAX);
	label_desktop_scale.setValue(nScale .. "%");
end

function onDiceScaleDown()
	local nScale = Interface.getDiceRelativeScale();
	if nScale > DICE_SCALE_MIN then
		Interface.setDiceRelativeScale(nScale - 10);
	end
	self.updateDiceDesktopDisplay();
end
function onDiceScaleUp()
	local nScale = Interface.getDiceRelativeScale();
	if nScale < DICE_SCALE_MAX then
		Interface.setDiceRelativeScale(nScale + 10);
	end
	self.updateDiceDesktopDisplay();
end

--
--	UI - COLOR SELECTORS
--

function updateDiceSkinDisplay()
	local tUserColor = UserManager.getColor();

	color_body.setValue(tUserColor.dicebodycolor);
	color_text.setValue(tUserColor.dicetextcolor);

	local bTintable = DiceSkinManager.isDiceSkinTintable(tUserColor.diceskin);
	label_color_body.setVisible(bTintable);
	label_color_text.setVisible(bTintable);
	color_body.setVisible(bTintable);
	color_text.setVisible(bTintable);

	for _,wDiceSkinGroup in ipairs(list_skin.getWindows()) do
		for _,wDiceSkin in ipairs(wDiceSkinGroup.list.getWindows()) do
			local bActive = (wDiceSkin.getID() == tUserColor.diceskin);
			wDiceSkin.setActive(bActive);
		end
	end
end

function onDiceBodyColorChanged(sColor)
	UserManager.setDiceBodyColor(sColor);
end
function onDiceTextColorChanged(sColor)
	UserManager.setDiceTextColor(sColor);
end
