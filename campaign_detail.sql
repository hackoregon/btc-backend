--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: campaign_detail; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE campaign_detail (
    candidate_name text,
    race text,
    website text,
    phone character varying,
    total double precision,
    grassroots double precision,
    instate double precision
);


ALTER TABLE public.campaign_detail OWNER TO postgres;

--
-- Data for Name: campaign_detail; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY campaign_detail (candidate_name, race, website, phone, total, grassroots, instate) FROM stdin;
Mary Walston	Director Eugene School District, Position 7	\N	(541)741-0600x123	522.889999999999986	0.420528218172082024	0.808755187515538987
Robert Lee	Director Reynolds School District, Position 1	\N	(800)952-9566x241	25	1	0
Ginny Burdick	State Senator 18th District		(503)244-1444	29132.2400000000016	0.0353491526913137996	0.755260838164177994
Dave Hunt	County Commissioner Clackamas County, Position 1, Chair	www.electdavehunt.com	(503)650-9434	111.790000000000006	1	0.767063243581715959
Nathan Hovekamp	State Representative 54th District		\N	1927.75	0.0695110880560239064	0.930488911943975983
Katie Eyre	State Representative 29th District	www.repeyrebrewer.com	\N	8200	0.024390243902439001	1
Fred Warner	County Judge Baker County	\N	(541)519-6704	10860.1399999999994	0.247247273055411998	0.450911314218784998
Bruce Starr	State Senator 15th District	www.brucestarr.org	(503)310-7500	113382.910000000003	0.0166066473333590994	0.733910516143922997
Jackie Dingfelder	State Senator 23rd District		(503)810-3972	2520	0.00793650793650793954	0.992063492063491981
LeeAnn Larsen	Director Beaverton School District, Zone 5	\N	(503)572-6763	1854.59999999999991	0	1
Richard Devlin	State Senator 19th District		(503)986-1719	111576.580000000002	0.00979578330864775033	0.890041709469854947
Tim Freeman	County Commissioner Douglas County, Position 2		(541)580-7545	75399	0.0580113794612660966	0.846695579516970054
Tim Freeman	County Commissioner Douglas County, Position 2		(541)580-7545	75399	0.0580113794612660966	0.846695579516970054
Tim Freeman	County Commissioner Douglas County, Position 2		(541)580-7545	75399	0.0580113794612660966	0.846695579516970054
Jodie Barram	City Councilor City of Bend, Position 6	\N	(541)408-5099	1000	0	1
Shemia Fagan	State Representative 51st District	www.shemiafagan.com	(503)226-8481	51660.8700000000026	0.0217611511381824996	0.938886433774731022
Lee Beyer	State Senator 6th District		(541)914-9104	54851.0999999999985	0.00546935248335950024	0.765729401962767953
Richard Cunningham	Director Lane Community College, Zone 1	\N	(541)232-7967	4643	0.0307990523368512001	0.969200947663149015
Jason Freilinger	City Councilor City of Silverton, At Large	\N	(503)874-4431	5	1	1
Janet Carlson	County Commissioner Marion County, Position 2	\N	(503)588-5212x5300	20265	0.124105600789539	0.870959782876881028
Tom Hughes	Metro Council President At Large	\N	(503)802-5723	108470	0.0244307181709228008	0.893057988383884949
PAUL HOLVEY	State Representative 8th District	\N	(541)344-5636	17918.5	0.0525708067081507996	0.743476853531267023
Charles Lee	State Representative 25th District		(503)584-4594	9544.69000000000051	0.0128867464527396992	1
Nicholas Fish	City Commissioner City of Portland, Position 2	\N	(503)823-3581	105723.729999999996	0.0764892612093802937	0.913495011952378033
Chris Garrett	Judge of the Court of Appeals Position 1	\N	\N	28448.1899999999987	0.000351516212454993011	0.797526661625924005
Tim Josi	County Commissioner Tillamook County, Position 3	\N	(503)842-3403	10368.1100000000006	0.127795712043949988	0.864006072466438013
Brian Boquist	State Senator 12th District		(503)623-4426	18860.7099999999991	0.0058698744638987603	0.416776993018820985
Brian Boquist	State Senator 12th District		(503)623-4426	18860.7099999999991	0.0058698744638987603	0.416776993018820985
Mark Hass	State Senator 14th District	markhass.com	(503)318-5570	37324.7699999999968	0.0106824502870346005	0.652286403908182044
Carolyn Tomei	State Representative 41st District		(503)986-1441	10775	0.0718329466357308932	0.837679814385151045
Greg Smith	State Representative 57th District	\N	(541)676-5154	12917.3199999999997	0.00900960880430306046	0.818000947564974989
Jenni Tan	City Councilor City of West Linn	\N	\N	163.72999999999999	1	1
Mark Johnson	State Representative 52nd District	www.repmarkjohnson.com	\N	71852.9900000000052	0.0326508333195320022	0.814537154264561969
Val Hoyle	State Representative 14th District	www.valhoyle.com	(541)905-1468	241345.529999999999	0.0113227288692689006	0.782838986079419041
JERRY BAKER	County Commissioner Umatilla County, Position 1	\N	\N	9362.28000000000065	0.104993655391634994	0.622955092135676014
Kali Ladd	Director Portland Community College, Zone 2	\N	\N	14721	0.282657428163847979	0.30636505672169001
Susie Jones	Director Mt. Hood Community College, Zone 1	\N	503 621-6316	746.909999999999968	1	0
Tim Knapp	Mayor City of Wilsonville	\N	(503)682-1267	50	1	0
Huma Pierce	Director Beaverton School District, Zone 7	\N	\N	15504.0799999999999	0.312562886672411	0.362748386231237008
Terry Fife	County Commissioner Umatilla County, Position 1	\N	(541)276-9338	8324	0.159058145122536992	0.858962037481979968
Richard Kimball	Director Salem-Keizer School District, Zone 5	\N	(503)362-3674	510.089999999999975	0.509890411496009999	0.490286027955851023
Thomas Colett	Director Beaverton School District, Zone 7	\N	\N	13555	0.225378089265954012	0.791589819254887028
Pamela Knowles	Director Portland School District, Zone 5	\N	(503)334-7668	6095	0.380639868744872989	0.484003281378178996
Michael Clarke	Commissioner Port of St Helens, Position 4	\N	(503)543-4800	10060.0699999999997	0.224051124892768988	0.794236024202614965
Tom Koehler	Director Portland School District, Zone 6	\N	(503)490-1070	35445	0.157426999576809001	0.662999012554661982
Kevin Robertson	Director Lake Oswego School District, Position 2	\N	(503)221-4699	5780	0.0484429065743944981	0.951557093425606015
Jaime Rodriguez	Director Hillsboro School District, Position 2	\N	(971)722-2601	7950	0.130817610062892997	0.592452830188679003
Susan Greenberg	Director Beaverton School District, Zone 1	\N	(971)230-2182	4106	0.336337067705796022	0.0706283487579152935
Anne Bryan	Director Beaverton School District, Zone 2	\N	(503)679-5040	7040.5	0.355088417015836988	0.57247354591293198
Regan Sonnen Molatore	Director West Linn-Wilsonville School District, Position 1	\N	\N	250	0	1
Jerry Jones	Director Tualatin Hills Park & Recreation, Position 2	\N	(503)718-7934	24860	0.0808527755430410028	0.860820595333870009
Donna Tyner	Director Beaverton School District, Zone 4	\N	(503)415-6436	3930.5	0.585167281516347004	0.313064495611244997
Sarah Howell	Director Lake Oswego School District, Position 2	\N	(503)784-1041	26634.2999999999993	0.201248765689355014	0.761769222393679946
Greg Cody	Director Tualatin Hills Park & Recreation, Position 2	\N	(503)246-8252	6747.60000000000036	0.208367419526942987	0.913621139368071988
Michael Richter	Director Beaverton School District, Zone 4	\N	(503)797-7316	200	1	1
Andrew Decker	Director Linn-Benton-Lincoln Education Service District, Zone 4	www.DeckerForStateRep.com	\N	30	1	0
Shawn Lindsay	State Representative 30th District	www.shawnlindsay.org	(503)389-3004	865.82000000000005	0.711256381233975055	0.538010209974359999
Angela Dilkes Perry	Director Canby School District, Position 7	\N	(971)219-2848	4085	0.363525091799266009	0.752753977968176002
Elizabeth Gerot	Director Eugene School District, Position 3	\N	(541)688-1040	3497.63999999999987	0.37100444871399002	0.584005214944933959
Steve Thoroughman	Director Canby Fire District, Zone 1	\N	(503)849-5743	2868.80000000000018	0.00871444506413831914	1
Janeen Sollman	Director Hillsboro School District, Position 1	\N	(503)430-6088	6693.97999999999956	0.296161625819020002	0.642962781484259005
David Matheson	Director Tigard-Tualatin School District, Position 3	\N	(503)727-2008	250	0	0
Martin Gonzalez	Director Portland School District, Zone 4	\N	(503)986-5813	17161.2099999999991	0.222747113985551998	0.800386452936594051
Jay Bengel	Director Beaverton School District, Zone 1	\N	(503)880-1170	3393.5	0.350670399292766	0.409341387947546986
Jennifer Williamson	State Representative 36th District	\N	(503)781-7233	51468.4499999999971	0.0871182248542553966	0.812334740991812021
Rebecca Lantz	Director Hillsboro School District, Position 6	\N	\N	3537.78999999999996	0	1
George Murdock	County Commissioner Umatilla County, Position 1	\N	(541)440-4751	13277.5699999999997	0.252047626184611018	0.767126816126746047
Stephen Fulton	Commissioner Port of Astoria, Position 2	\N	(503)861-3305	3798	0.197472353870458001	0.375197472353870021
Armand Vial	Director Hillsboro School District, Position 1	\N	\N	1475	0.118644067796610006	0.881355932203390036
Benjamin Unger	State Representative 29th District	benunger.com	(503)351-8833	38432.9000000000015	0.0396925550765099971	0.931686133494999957
Joseph Gallegos	State Representative 30th District		(503)347-6873	27189.6500000000015	0.0665654026440208046	0.868795663055610956
Sam Chase	Metro Councilor District 5	\N	(503)810-4504	1405	0.142348754448399006	0
Glenn Miller	Director Hillsboro School District, Position 2	\N	(360)936-3592	140	1	0
Joe Pishioneri	State Representative 12th District	\N	(541)579-8778	1881.57999999999993	0	1
Michael Reardon	State Representative 48th District	www.reardonfororegon.com	\N	12789.1200000000008	0.0488696642145824006	0.813191212530650964
Thuy Tran	Director Parkrose School District #3, Position 1		(503)284-9071	6078	0.349292530437644022	0.446692991115498983
Jeff Barker	State Representative 28th District	\N	(503)986-1428	29345.8300000000017	0.0271190148651444009	0.695868203421065035
Tina Kotek	State Representative 44th District		(503)449-9767	212932.190000000002	0.00503446660648161973	0.717790673171585958
Tom Turner	County Sheriff Lane County	\N	(541)359-8620	500	0	0
Linda Degman	Director Beaverton School District, Zone 7	\N	(971)722-4423	1090	0.458715596330274977	0.229357798165137988
James Knapp	Commissioner Oak Lodge Water District, Position 2	\N	\N	2180.36999999999989	0.0914065044006292932	1
Gayle Strawn	Director Salem-Keizer School District, Zone 5	\N	\N	891.690000000000055	0.526180623310791962	0.908948177057049
James Campbell	Commissioner Port of Astoria, Position 1	\N	(503)791-2765	3240	0.336419753086420026	0.331790123456789987
Jack Esp	County Commissioner Umatilla County, Position 1		\N	3332.34999999999991	0.157447446996863999	0.867961048509309996
Jill Halliburton	Commissioner Port of Bandon, Position 1	\N	\N	2048.17000000000007	0.310032858600603978	0.787615285840530976
Don Chance	Commissioner Port of Bandon, Position 3	\N	(541)297-2667	2320	0.0086206896551724102	0.862068965517240993
Erik Seligman	Director Hillsboro School District, Position 6	\N	\N	5985.38000000000011	0.304849483240829999	0.700937952143389054
Steve Buel	Director Portland School District, Zone 4	\N	\N	17439.869999999999	0.17018016762739599	0.914769433487749972
Karen Delaney	Director Lake Oswego School District, Position 3	\N	\N	1292.04999999999995	0.226036144112069987	0.992260361441120953
Sharon Stiles	Director Lane Community College, Zone 1	\N	(541)991-0053	4514.69999999999982	0.473940682658870016	0.365472788889626976
Greg Evans	City Councilor City of Eugene, Ward 6	\N	(541)463-5340	3515.42999999999984	0.274626432612796012	0.824934645263880051
Vivian Scott	Director North Clackamas School District, Position 5	\N	\N	5463.8100000000004	0.590247464681239009	0.403529771350028987
Tobias Read	State Representative 27th District	www.tobiasread.com	(503)532-4491	65375.010000000002	0.0896786096093905027	0.62135730457249605
Matthew Keating	Director Lane Community College, Zone 4	\N	\N	12671.5100000000002	0.24996073869649299	0.538609842078805023
John Lively	State Representative 12th District		(541)484-7052	27482.130000000001	0.0423322355290510974	0.875919370150712973
Dwight Coon	Commissioner Port of Siuslaw, Position 3	www.coonforhouserep.com	\N	2400.82000000000016	0.0299397705783857014	0.970060229421613962
Keith Steele	Director West Linn-Wilsonville School District, Position 5	\N	(503)808-1205	2393.73000000000002	0.293988879280453974	0.77441064781742297
Arnie Roblan	State Senator 5th District	arniefororegon.com	(541)297-2414	91854.2799999999988	0.00422952528722668041	0.932626982651217018
Mark Braverman	Municipal Judge City of West Linn	\N	(503)655-9711	36.0900000000000034	1	1
Robert Stacey	Metro Councilor District 6	\N	(503)770-0469	259.129999999999995	0	0
Floyd Prozanski	State Senator 4th District		(541)342-2447	15047.6000000000004	0.0578165288816821013	0.716233818017490975
Jules Bailey	County Commissioner Multnomah County, District 1	julesfororegon.com	(503)736-2502	180480.809999999998	0.0619353935745301995	0.732734743377979947
Shirley Craddick	Metro Councilor District 1	\N	\N	41335	0.178541187855327993	0.75117938792790595
Michael Dembrow	State Senator 23rd District	michaeldembrow.com	(503)914-9723	40498.5	0.128733162956652991	0.719458745385632037
Michael Dembrow	State Senator 23rd District	michaeldembrow.com	(503)914-9723	40498.5	0.128733162956652991	0.719458745385632037
Michael Dembrow	State Senator 23rd District	MichaelDembrow.com	(503)914-9723	40498.5	0.128733162956652991	0.719458745385632037
Steve Spinnett	Mayor City of Damascus	\N	(503)312-3450	24641.9399999999987	0.107200975247890004	0.954021477205122981
Lisa Christon	Director Eugene School District, Position 3	\N	\N	2000	0.349999999999999978	0.699999999999999956
Nancy Nathanson	State Representative 13th District	nancynathanson.org	\N	41707.6600000000035	0.070794189844263597	0.702380809664220007
Katherine Schacht	Director Emerald People's Utility District, Subdivision 4	\N	(541)221-8779	304.279999999999973	1	0
Christopher Cochran	State Senator 25th District	\N	\N	1115	0.103139013452914999	0.672645739910313956
Roger Nyquist	County Commissioner Linn County, Position 2	\N	(541)908-3930	3250	0	0.923076923076923017
Bill Kennemer	State Representative 39th District	www.billkennemer.com	(503)986-1439	44577.7200000000012	0.0421223875963148975	0.755490410904820053
Edward Truax	City Councilor City of Tualatin, Position 4	\N	(503)670-1958	100	1	0
Martha Schrader	County Commissioner Clackamas County, Position 3	www.marthaschrader.com	(503)655-8581	800	0.0625	0.9375
Bill Bradbury	Governor statewide	www.bradbury2010.com	\N	8032.88000000000011	0	1
Kitty Piercy	Mayor City of Eugene	\N	(541)682-5010	20	1	0
Leslie Lewis	County Commissioner Yamhill County, Position 2	\N	(503)577-4321	100	1	0
Rod Park	Metro Councilor District 1	\N	(503)663-3715	233.759999999999991	1	0.772715605749486945
Bob Hermann	District Attorney Washington County	\N	(503)846-8671	100	1	0
Andy Duyck	County Commissioner Washington County, At Large	duyck4statehouse.com	(503)357-0123	100389.440000000002	0.040043056321461698	0.934909488488032014
R. Butler	County Judge Malheur County	\N	(503)930-9304	13	1	0
Ron Saxton	Governor statewide	\N	(503)478-4463	1.81000000000000005	1	0
Lou Ogden	Mayor City of Tualatin	\N	(503)692-0163	1250	0.200000000000000011	0.800000000000000044
Bill Morrisette	State Senator 6th District	\N	\N	150	1	0
Keith Mays	Mayor City of Sherwood	\N	(503)643-6305	50	1	0
Ted Wheeler	State Treasurer statewide	\N	\N	26383.7999999999993	0.00507887415762703007	0.720138873096370036
LaVonne Griffin-Valade	City Auditor City of Portland	\N	(503)988-5709	101.280000000000001	1	0
Kate Brown	Secretary of State statewide	\N	(503)963-9611	3211.34000000000015	0.397422882659574983	0.175826913375725008
Jim Bernard	County Commissioner Clackamas County, Position 5	\N	(503)655-8581	68457.2599999999948	0.146380676059778003	0.734476664710214999
Salvador Peralta	State Representative 24th District	\N	(503)687-1206	8.60999999999999943	1	0
Kathryn Harrington	Metro Councilor District 4	\N	(503)797-1553	10955	0.235052487448654007	0.712460063897763951
Alan Bates	State Senator 3rd District	http://www.alanbates.net/	(541)282-6502	117220	0.0278706705340386017	0.842923562531990966
Dan Saltzman	City Commissioner City of Portland, Position 3	\N	(503)224-5160	106515.619999999995	0.0206976216258235	0.954093117985888028
Chris Edwards	State Senator 7th District	http://chrisedwardsfororegon.com	(541)986-1707	29148.5	0.00514606240458342998	0.854194898536802971
Thomas Balmer	Judge of the Supreme Court Position 1		(503)986-5717	4100	0.024390243902439001	0.975609756097560954
Thomas Balmer	Judge of the Supreme Court Position 1		(503)986-5717	4100	0.024390243902439001	0.975609756097560954
Betty Bode	City Councilor City of Beaverton, Position 2	\N	(503)804-2247	731	0.586867305061559041	0.686730506155950993
Faye Stewart	County Commissioner Lane County, East Lane, Position 5	\N	(541)942-0870	29770	0.0428283506886127027	0.883439704400402981
Patti Milne	State Senator 11th District	\N	(503)551-5590	8157.5	0.0239043824701195007	0.798345081213607033
David Nelson	State Senator 28th District		(541)278-2332	18.8999999999999986	1	1
Deborah Boone	State Representative 32nd District		(503)739-3305	15097.6299999999992	0.00315479979308011006	0.847815186886949013
Wayne Krieger	State Representative 1st District		(541)247-7990	13740	0.0138282387190684	0.691411935953420986
john lindsey	County Commissioner Linn County, Position 1	\N	(541)967-3825	3056	0.149214659685864004	0.934554973821989043
Bruce Cuff	State Representative 17th District	www.BruceCuff.com	(503)371-3013x1141	7700	0.123376623376623001	0.889610389610389962
Bruce Cuff	State Representative 17th District	www.time4cuff.com	(503)371-3013x1141	7700	0.123376623376623001	0.889610389610389962
Mike Ainsworth	County Commissioner Polk County, Position 3	\N	(503)838-8681	4977	0.114928671890696998	0.431384368093228998
Daniel Jaffer	County Commissioner Polk County, Position 2	\N	\N	5479.23999999999978	0.405026974543915008	0.445105525583839978
Michael Spasaro	State Senator 6th District	MichaelSpasaro.com	(541)401-5674	3310	0.244712990936555991	0.60422960725075503
Lisa Shaw-Ryan	City Councilor City of Lake Oswego	\N	(503)675-7861	23.6000000000000014	1	0
Jerry Rust	County Commissioner Lane County, West Lane, Position 1	\N	(541)997-1664	78.6800000000000068	1	0
Kyle Palmer	Mayor City of Silverton	\N	(503)873-5701	50	1	0
Debra Birkby	County Commissioner Clatsop County, District 5	\N	(503)739-1099	0.110000000000000001	1	1
Daniel Staton	County Sheriff Multnomah County	\N	(503)988-4404	25402	0.135146838831588012	0.840170065349185036
Anthony DeBone	County Commissioner Deschutes County, Position 1	\N	541536-1079	6870.09000000000015	0.308584021461144997	0.553122302619033945
Cliff Bentz	State Representative 60th District		(541)889-5368	52804.1200000000026	0.0152283571812200005	0.822852459239923006
Melody Thompson	County Clerk Clackamas County	\N	\N	375	0	1
Sherrie Sprenger	State Representative 17th District	www.sherriesprenger.com	\N	7252.5	0.0827300930713547045	0.696311616683901957
Jay Bozievich	County Commissioner Lane County, West Lane, Position 1	\N	(541)953-6555	58744	0.0296881383630668988	0.935414680648235963
Peter Buckley	State Representative 5th District	www.peterbuckley.org	(541)488-9180	70342.7200000000012	0.0391683744956123001	0.787423346723015949
Laurie Monnes Anderson	State Senator 25th District	http://www.lauriemonnesanderson.com/	(503)666-9751	56103.0400000000009	0.0354258877950286016	0.702823590308119028
Sal Esquivel	State Representative 6th District	\N	(541)494-4944	26619.1800000000003	0.0868238615915291057	0.77534582207265601
Douglas Whitsett	State Senator 28th District	www.doughwhitsett.com	(541)882-1315	14819.25	0.0108453531723940004	0.537763382087487973
Douglas Whitsett	State Senator 28th District		(541)882-1315	14819.25	0.0108453531723940004	0.537763382087487973
Betty Taylor	City Councilor City of Eugene, Ward 2	\N	(541)338-9947	1087.94000000000005	0.381454859642995026	0.434711473059176012
John Huffman	State Representative 59th District		(503)986-1459	31208	0.0507882594206613969	0.580716482953088975
John Huffman	State Representative 59th District	votehuffman.com	(503)986-1459	31208	0.0507882594206613969	0.580716482953088975
Chris Telfer	State Senator 27th District	telferforsenate.com	(541)389-3310	1222.75999999999999	0	1
Vic Gilliam	State Representative 18th District	\N	(503)986-1418	20314	0.0129959633750123	0.617306783499064982
Catherine McKeown	State Representative 9th District	www.caddymckeown.com	\N	50263.5199999999968	0.0531900670705115972	0.752629939168605988
Gail Whitsett	State Representative 56th District		(541)891-6109	10575	0.0165484633569739983	0.723404255319148981
Gail Whitsett	State Representative 56th District		(541)891-6109	10575	0.0165484633569739983	0.723404255319148981
Warren Bednarz	City Councilor City of Salem, Ward 7	\N	(503)363-6141	100	1	0
Bruce Altizer	City Commissioner City of Portland, Position 1	\N	(503)261-1575	100	1	0
Diane Rosenbaum	State Senator 21st District		(503)231-9970	47883.0800000000017	0	0.83292636981581003
Rob Handy	County Commissioner Lane County, North Eugene, Position 4	\N	(541)543-0845	5020	0.196215139442231012	0.602589641434262968
Dick Schouten	County Commissioner Washington County, District 1	\N	(503)846-8681	13	1	0
Brent Barton	State Representative 40th District	www.VoteBrentBarton.com	\N	29445.1899999999987	0.0396669201319468992	0.959484044762489052
Dan Clem	County Commissioner Polk County, Position 1	\N	(503)480-9983	475	0	1
Alex Gardner	District Attorney Lane County	www.gardnerforda.com	(541)682-4261	700	0	0
Scott Rose	Mayor City of Portland	\N	(503)274-2675	3083.76000000000022	0	1
Bill Dant	Mayor City of Portland	\N	(503)781-2999	60	1	0
Bradley Witt	State Representative 31st District	www.votebradwitt.com	(503)684-2822	49869.8099999999977	0.00844198123072856937	0.914357002763795945
Aaron Felton	District Attorney Polk County		(503)945-9009	963.92999999999995	1	0.325677175728528001
Keith Heck	County Commissioner Josephine County, Position 2	\N	(541)660-6870	50.1199999999999974	1	0.00239425379090183995
Colleen Roberts	County Commissioner Jackson County, Position 2	\N	(541)826-5622	1875.65000000000009	0	1
Christopher Humphreys	County Sheriff Wheeler County	\N	\N	250	0	1
Earl Fisher	County Commissioner Columbia County, Position 1	\N	(503)728-2450	1126.92000000000007	0.133106165477584998	0.91126255634827702
Linda Simmons	County Commissioner Malheur County, Position 2	\N	\N	200	1	1
Christopher Gorsek	State Representative 49th District	chrisgorsek.com	(503)901-6052	14680	0.0974114441416893961	0.877043596730245012
Douglas Daoust	Mayor City of Troutdale	\N	(503)808-2913	1550	0.0322580645161289967	0.967741935483870996
Manuel Castaneda	State Representative 28th District	www.manuelfororegon.com	(503)642-5696	45	1	0
Gene Whisnant	State Representative 53rd District	\N	(541)986-1453	22500	0.0200000000000000004	0.400000000000000022
John Nelsen	State Representative 49th District		\N	4508.64999999999964	0.0998081465627183029	0.972275514843689015
Fred Girod	State Senator 9th District	www.fredgirod.com	(503)769-4321	15110.7099999999991	0.0304889710675407995	0.540061320745351958
Sid Leiken	County Commissioner Lane County, Springfield, Position 2	\N	(541)520-3670	7550	0.00662251655629138986	0.99337748344370902
Jeremy Ferguson	County Commissioner Clackamas County, Position 5	\N	\N	8638.96999999999935	0.126053221622485001	0.868039824192003984
Rick Dyer	County Commissioner Jackson County, Position 1	\N	(541)773-6937	11912.5	0.0587618048268625029	0.550891920251835976
W. Rod Monroe	State Senator 24th District	\N	(503)986-1724	22896.2999999999993	0.0535020942248310982	0.87225010154479099
Brad Avakian	Commissioner of the Bureau of Labor and Industries statewide	\N	(503)970-9296	279975.260000000009	0.0807254898164931067	0.890564080554832049
Kim Thatcher	State Senator 13th District	www.kimthatcher.com	(503)986-1425	13223.0599999999995	0.0395566533011270025	0.542465964761560948
Brian Clem	State Representative 21st District	www.brianclem.com	(503)931-2536	41950	0	0.833134684147795013
Mary Nolan	City Commissioner City of Portland, Position 1		(503)236-8801	678.580000000000041	0.408986412803207022	0.221049839370450002
Peter Courtney	State Senator 11th District		(503)986-1600	146403.630000000005	0.00402059703027855039	0.808611302875481996
Lawrence George	State Senator 13th District	\N	(503)341-8546	15360.7099999999991	0.00720734913946035043	0.674494212832610018
Carl Hosticka	State Representative 37th District		\N	2525	0.0396039603960395975	0.960396039603960028
Daniel Holladay	County Commissioner Clackamas County, Position 4	\N	(971)404-9158	2500	0	1
Cherryl  Walker	County Commissioner Josephine County, Position 3	\N	(541)840-8470	100	1	0
Vicki Berger	State Representative 20th District	www.vickiberger.net	(503)871-0647	18383.5299999999988	0.0285581713631712988	0.397558575529292024
Timothy Bishop	County Commissioner Coos County, Position 2	\N	(541)751-9663x111	50	1	0
Julie Parrish	State Representative 37th District	julie4oregon@gmail.com	(503)986-1437	50637.9700000000012	0.0162921222947918012	0.753873229910283049
James "Jim" Egan	Judge of the Court of Appeals Position 6	\N	(541)967-3865	8941	0.109048204898781004	0.555418856951124029
Vance Day	Judge of the Circuit Court 3rd District, Position 5		\N	300	0	0
Craig Pope	County Commissioner Polk County, Position 2	agriweld.com	(503)551-6929	8490	0.265017667844523019	0.758539458186101023
Ted Ferrioli	State Senator 30th District		(541)490-6528	69676.6999999999971	0.00245046048392074008	0.70219599952351397
Ron Le Blanc	Mayor City of West Linn	\N	(503)723-9360	1572.84999999999991	0	1
David Orr	Judge of the Circuit Court 1st District, Position 7		(541)608-2902	680.090000000000032	0	1
Monica Keenan	City Councilor City of Wilsonville	\N	(503)427-0909	25.4699999999999989	1	0
\.


--
-- PostgreSQL database dump complete
--

