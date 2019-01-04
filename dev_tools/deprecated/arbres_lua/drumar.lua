defaultbordure="#00FFF5"
defaultfond="0 168 162"


arbre={
{id="toile",img="attacks/entangle.png",txt="Entangle <BR /> <B> +2</B> dmg",max_level=2},
{id="toile_atk",img="attacks/entangle.png",txt="Entangle  <BR /> <B> +1</B> str",max_level=3,parents={"toile"}},
{id="toile_snare",levelbonus=true,img="attacks/entangle_snare.png",txt="Entangle  <BR/><B>Snare</B>",max_level=1,parents={"toile_atk"},couleur={28 ,220, 63}},
{id="wave",img="attacks/iceball.png",txt="Chill wave <BR /> <B> +2</B> dmg",max_level=3},
{id="wave_atk",img="attacks/iceball.png",txt="Chill wave  <BR /> <B> +1</B> str",max_level=2,parents={"wave"}},
{id="wave_arch_magical",levelbonus=true,img="attacks/iceball_arch_magical.png",txt="Chill wave  <BR /><B>Arch Magical </B>",couleur={69, 117, 174},max_level=1,parents={"wave_atk"}},
{id="wave_weaker_slow1",img="icons/iceball_slow.png",txt="<B> Slowing</B><BR />  Chill wave  ",couleur={145 ,145 ,145},max_level=1,parents={"wave_atk"}},
{id="wave_weaker_slow2",img="icons/iceball_slow.png",txt="<B> Freezing</B><BR />  Chill wave  ",couleur={145 ,145 ,145},max_level=1,parents={"wave_weaker_slow1"}},
{id="wave_res1",img="icons/iceball_res.png",txt="<B> Weakening </B><BR />  Chill wave ",couleur={185, 92, 67},max_level=1,parents={"wave_atk"}},
{id="wave_res2",img="icons/iceball_res.png",txt="<B> Cracking </B><BR />  Chill wave ",couleur={185, 92, 67},max_level=1,parents={"wave_res1"}},
{id="attack_chilled",levelbonus=true,img="attacks/touch-undead.png",txt="<B> Chilling touch</B> ",couleur={30, 217, 208},max_level=3,parents={"wave_arch_magical","wave_res2","wave_weaker_slow2"}},

{id="hp",img="icons/amla-default.png",txt="Health <BR/> <B> +7 </B> hp",max_level=2},
{id="though",img="icons/helmet_chain-coif.png",txt="Magic resistances <BR/>  <B> +7 </B> %",max_level=3,parents={"hp"}}}




