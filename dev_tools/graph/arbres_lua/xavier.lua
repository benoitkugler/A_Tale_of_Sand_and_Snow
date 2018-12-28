defaultbordure="#a99508"
defaultfond="181 167 71"


arbre={
{id="bow",img="attacks/bow-elven.png",txt="Bow <BR /> <B> +2</B> dmg",max_level=2},
{id="bow_atk",img="attacks/bow-elven.png",txt="Bow <BR /> <B> +1</B> str",max_level=1,parents={"bow"}},
{id="bow_precis",levelbonus=true,img="attacks/bow_precis.png",txt="Bow <BR /> <B> Precision</B>",max_level=1,parents={"bow_atk"},couleur={69, 117, 174}},
{id="bow_pierce",img="icons/arrow_strong.png",txt="<B> Piercing </B> <BR />  Arrows",max_level=1,parents={"bow_precis"},couleur={214, 220, 220}},
{id="bow_fire",img="attacks/bow-elven-fire.png",txt="<B> Fire </B> <BR />  Bow",max_level=1,parents={"bow_precis"},couleur={214, 68, 17}},
{id="bow2",img="attacks/bow-elven.png",txt="Bow <BR /> <B> +2</B> dmg",max_level=2,parents={"bow_precis"}},
{id="bow_atk2",img="attacks/bow-elven.png",txt="Bow <BR /> <B> +1</B> str",max_level=1,parents={"bow2"}},
{id="bow_focus",levelbonus=true,img="attacks/bow_focus.png",txt="Bow <BR /> <B> Focus </B>",max_level=1,parents={"bow_fire","bow_pierce"},couleur={69, 117, 174}},
{id="bloodlust",levelbonus=true,img="icons/blood-frenzy.png",txt="<B> Bloodlust </B>",max_level=1,parents={"bow_focus","bow_atk2"},couleur={54, 255, 5}},
{id="sword",img="attacks/sword-elven.png",txt="Sword <BR /> <B> +1 </B> dmg",max_level=3},
{id="sword_atk",img="attacks/sword-elven.png",txt="Sword <BR /> <B> +1</B> str",max_level=1,parents={"sword"}},
{id="pm",img="icons/boots_elven.png",txt="Moves <BR/>  <B> +1 </B>",max_level=2},
{id="skirmisher",img="icons/sandals.png",txt="Skirmisher",max_level=1,parents={"pm"}},
{id="movement",levelbonus=true,img="icons/sandals.png",txt="Faster on <BR /> sand &amp; snow",max_level=1,parents={"skirmisher"}},
{id="hp",img="icons/amla-default.png",txt="Health <BR/> <B> +5 </B> hp",max_level=2},
{id="though",img="icons/cuirass_leather_studded.png",txt="Resistances <BR/>  <B> +5 </B> %",max_level=2,parents={"hp"}}}




