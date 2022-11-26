package entities.interact;

import quest.GlobalQuestState;
import states.PlayState;

class Journal extends GenericInteractable {

	public function new(data:Entity_Interactable) {
		super(data);
	}

	override function interact() {
		if (GlobalQuestState.HAS_INTERACTED_WITH_GATE) {
			dialogBox.loadDialogLine('On the second page, the number <color id=keyItem>509</color> is circled.');
			PlayState.ME.openDialog(dialogBox);
		} else {
			super.interact();
		}
	}
}