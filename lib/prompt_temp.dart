and right now the user details cant be edited, nor are fetched dynamically, (got from the static template data)
so, i need that also be done

and when they first register as an agent, we only have their number, their name and email have to be filled in, maybe you can make it part of onboarding
and also areas the agent deals in
inorder to add an area, it needs to be added with help from google maps api
we get only the main title - they can only pick administrative level 3 or 4 or something

and its like a toggle they can click and see everything
idk the best UI way to do this, so it fits, because if they have like 10 areas under them, then it just takes too much space


-----------------

hmm, okay so here's the functionality I want to change

so, for the agent

there are properties he posted and properties which are assigned to him by landandplot
on the card, we can write LANDANDPLOT as a tag at the top right

both lists together make all the properties the agent has to manage

so we need to change these headings of posted and assigned actually
to 'find buyer' & 'sales in progress' should be the headings

so in the find buyer
agent can manually add interested buyers and buyers who click interested in the property details page get added (change property details page code to have a button which does that instead of call/message)

once a interested buyer is added, status defaults to pending
and then, of all the interested buyers, we can set the date for their visit, or change it to them not visiting
and then after the date of visit or if they're not visiting, then immediately, then the agent has to give the price they proposed and any notes, and thats the paperwork
then the status changes to negotiating till its either rejected or accepted
and only one buyer can be changed to accepted

then that property is moved to sales in progress
and then the timeline view and proof uploading is exactly how it should be, no changes to that

once its in accept, its card in 'find buyer' - its greyed out and brought to the bottom there, its added to sale initiated

and we also want to be able to assign multiple agents to a property - who can find buyers and who finds an accept first, we can make him the one who gets to take it to sale initiated 

tell all the changes to UI and services

