 

ES = {}

local Scenario_event={
	{id="prestart",name="prestart",T.lua{code="ES.prestart()"}},
	{id="turn1",name="turn_1",T.lua{code="ES.turn1()"}}
}

for i,v in pairs(Scenario_event) do
    --    wesnoth.remove_event_handler(v.id)
        wesnoth.add_event_handler(v)
end

-- Ces 2 fonctions sont toujours appelés par la macro STANDARD_EVENT
function ES.atk()
end

function ES.kill()
end

function ES.prestart()
	wesnoth.put_unit({
		id="egil",
		type="Grand MarshalN",
		side=2,
		name = "Egil Skinir"
	},10,4)
	wesnoth.put_unit({
		id="ran",
		type="Iron MaulerN",
		side=2,
		name = "Ran Gragass"
	},7,6)
	wesnoth.put_unit({
		id="harbar",
		type="GeneralN",
		side=2,
		name = "Harbar Augentyr"
	},8,5)
	wesnoth.put_unit({
		id="urvi",
		type="Red MageN",
		side=2,
		name = "Urvi Herjar"
	},9,5)
	wesnoth.put_unit({
		id="bragi",
		type="Master at ArmsN",
		side=2,
		name = "Bragi Daldr"
	},11,5)
	wesnoth.put_unit({
		id="dummy1",
		type="Master BowmanN",
		side=2,
		name = "Zac Tod"
	},12,5)
	wesnoth.put_unit({
		id="dummy3",
		type="Royal GuardN",
		side=2,
		name = "Ulk Zappsnhcip"
	},13,6)

	wesnoth.put_unit({
		type="SwordsmanN",
		side=2,
	},8,21)
	wesnoth.put_unit({
		type="SwordsmanN",
		side=2,
	},12,21)

end


function ES.turn1()     
	wesnoth.fire("move_unit",{id="vranken",to_x = 10, to_y=7})
	
	wesnoth.fire("message", {speaker = "egil", message = _"Captain Xaintrailles, please have a sit !"})
	
	wesnoth.fire("message", {speaker = "ran", message = _"You're here because of worrying news from Dead Island. Its garrison seems under attack. Our magi received this message yesterday, send through the White Arks by Jödumur, commanding Dead Island company."})
	
	wesnoth.fire("message", {speaker = "narrator", message = _ "<i>(projection)</i> Communication Mage for Dead Island here ! We are under attack from Muspell. They outnumber us by far ! We request immediate help ! They have already broke our first line and ... "})
	
	wesnoth.fire("message", {speaker = "harbar", message = _"The message stops here, so we fear muspellians have already taken the White Arks facility.."})
	
	wesnoth.fire("message", {speaker = "urvi", message = _"<i>(thumping the table)</i> What an arrogance from Muspell ! " ..
					"They openly dare to attack the Federation ! They will pay for this insult !"})
	
	wesnoth.fire("message", {speaker = "bragi", message = _"The Council share Herjar's opinion. Your mission, Vranken, is to lead Nifhell forces and take back Dead Island !"})
	
	wesnoth.fire("message", {speaker = "vranken", message = _"<i>(Thinking for a while)</i> It's rather strange to me that Muspell attacks Dead Island. We have always letting them use the White Arks. What's would be the point ?"})
	
	wesnoth.fire("message", {speaker = "egil", message = _"That doesn't matter. We have to stop Muspell invasion !"})
	
	wesnoth.fire("message", {speaker = "harbar", message = _"We omitted a detail : the muspellian troops are displaying Octopus flag !"})

	wesnoth.fire("message", {speaker = "narrator", message = _ "Vranken thrilled. Octopus was the best general of Muspell. " .. 
					"He quickly earned his reputation by defeating Nifhell in small skirmishes during the last two years. " .. 
					"His name came from he ability to move his troops like tentacles, thus winning already lost battles."})

	wesnoth.fire("message", {speaker = "vranken", message = _ "That's not a detail ! When should we head towards the White Arks ?"})
end