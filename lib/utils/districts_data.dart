// Example data structure for districts and mandals
const districtData = {
  'Adilabad': [
    'Adilabad (Rural)',
    'Adilabad (Urban)',
    'Bazarhathnoor',
    'Bela',
    'Bheempur',
    'Boath',
    'Gadiguda',
    'Gudi Hathnur',
    'Ichoda',
    'Inderavelly',
    'Jainad',
    'Mavala',
    'Narnoor',
    'Neradigonda',
    'Sirikonda',
    'Talamadugu',
    'Tamsi',
    'Utnur'
  ],
  'Bhadradri Kothagudem': [
    'Allapalli',
    'Annapureddypalli',
    'Aswapuram',
    'Aswaraopeta',
    'Bhadrachalam',
    'Burgampadu',
    'Chandrugonda',
    'Cherla',
    'Chunchupally',
    'Dammapeta',
    'Dummagudem',
    'Gundala',
    'Julurpad',
    'Karakagudem',
    'Kothagudem',
    'Laxmidevipally',
    'Manuguru',
    'Mulakalapalle',
    'Palwancha',
    'Pinapaka',
    'Sujathanagar',
    'Tekulapalle',
    'Yellandu'
  ],
  'Hanumakonda': [
    'Atmakur',
    'Bheemadevarpalle',
    'Damera',
    'Dharmasagar',
    'Elkathurthi',
    'Hanumakonda',
    'Hasanparthy',
    'Inavolu',
    'Kamalapur',
    'Khazipet',
    'Nadikuda',
    'Parkal',
    'Shayampet',
    'Velair'
  ],
  'Jagtial': [
    'Beerpur',
    'Bheemaram',
    'Buggaram',
    'Dharmapuri',
    'Endapalli',
    'Gollapalle',
    'Ibrahimpatnam',
    'Jagtial',
    'Jagtial Rural',
    'Kathlapur',
    'Kodimial',
    'Korutla',
    'Mallapur',
    'Mallial',
    'Medipalle',
    'Metpalli',
    'Pegadapalle',
    'Raikal',
    'Sarangapur',
    'Velgatoor'
  ],
  'Jangaon': [
    'Bachannapeta',
    'Chilpur',
    'Devaruppula',
    'Ghanpur (Stn)',
    'Jangaon',
    'Kodakandla',
    'Lingala Ghanpur',
    'Narmetta',
    'Palakurthi',
    'Raghunatha Palle',
    'Tharigoppula',
    'Zaffergadh'
  ],
  'Jayashankar Bhupalpalli': [
    'Bhupalpally',
    'Chityal',
    'Ghanapur Mulug',
    'Kataram',
    'Kothapallegori',
    'Mahadevpur',
    'Malharrao',
    'Mogullapalle',
    'Mutharam Mahadevpur',
    'Palimela',
    'Regonda',
    'Tekumatla'
  ],
  'Jogulamba Gadwal': [
    'Alampur',
    'Dharoor',
    'Gadwal',
    'Ghattu',
    'Ieeja',
    'Itikyal',
    'Kaloor Timmanadoddi',
    'Maldakal',
    'Manopad',
    'Rajoli',
    'Undavelly',
    'Waddepalle',
    'Yerravalli'
  ],
  'Kamareddy': [
    'Banswada',
    'Bhiknoor',
    'Bibipet',
    'Bichkunda',
    'Birkur',
    'Domakonda',
    'Dongli',
    'Gandhari',
    'Jukkal',
    'Kamareddy',
    'Lingampet',
    'Machareddy',
    'Madnoor',
    'Mohammadnagar',
    'Nagireddypet',
    'Nasrullabad',
    'Nizamsagar',
    'Palvancha',
    'Pedda Kodapgal',
    'Pitlam',
    'Rajampet',
    'Ramareddy',
    'Sadasivanagar',
    'Tadwai',
    'Yellareddy'
  ],
  'Karimnagar': [
    'Chigurumamidi',
    'Choppadandi',
    'Ellandakunta',
    'Gangadhara',
    'Ganneruvaram',
    'Huzurabad',
    'Jammikunta',
    'Karimnagar',
    'Karimnagar Rural',
    'Kothapalli',
    'Manakondur',
    'Ramadugu',
    'Shankarapatnam',
    'Thimmapur',
    'Veenavanka',
    'V. Saidapur'
  ],
  'Khammam': [
    'Bonakal',
    'Chinthakani',
    'Enkoor',
    'Kallur',
    'Kamepalle',
    'Khammam Rural',
    'Khammam Urban',
    'Konijerla',
    'Kusumanchi',
    'Madhira',
    'Mudigonda',
    'Nelakondapalle',
    'Penuballi',
    'Raghunadhapalem',
    'Sathupalle',
    'Singareni',
    'Thallada',
    'Thirumalayapalem',
    'Vemsoor',
    'Wyra',
    'Yerrupalem'
  ],
  'Kumuram Bheem (Asifabad)': [
    'Asifabad',
    'Bejjur',
    'Chintala Manepally',
    'Dahegaon',
    'Jainoor',
    'Kagaz Nagar',
    'Kerameri',
    'Kouthala',
    'Lingapur',
    'Penchikalpet',
    'Rebbena',
    'Sirpur (T)',
    'Sirpur (U)',
    'Tiryani',
    'Wankdi'
  ],
  'Mahabubabad': [
    'Bayyaram',
    'Chinnagudur',
    'Danthalapalle',
    'Dornakal',
    'Gangaram',
    'Garla',
    'Gudur',
    'Inugurthy',
    'Kesamudram',
    'Kothaguda',
    'Kuravi',
    'Mahabubabad',
    'Maripeda',
    'Narsimhulapet',
    'Nellikudur',
    'Peddavangara',
    'Seerole',
    'Thorrur'
  ],
  'Mahabubnagar': [
    'Addakal',
    'Balangar',
    'Bhoothpur',
    'Chinna Chintha Kunta',
    'Devarkadara',
    'Gandeed (M)',
    'Hanwada',
    'Jadcherla',
    'Koilkonda',
    'Koukuntla',
    'Mahabubnagar (Urban)',
    'Mahabubnagar Rural',
    'Midjil',
    'Mohammadabad',
    'Moosapet',
    'Nawabpet',
    'Rajapur'
  ],
  'Mancherial': [
    'Bellampalle',
    'Bheemaram',
    'Bheemin',
    'Chennur',
    'Dandepalle',
    'Hajipur',
    'Jaipur',
    'Jannaram',
    'Kannepalli',
    'Kasipet',
    'Kotapalle',
    'Luxettipet',
    'Mancherial',
    'Mandamarri',
    'Naspur',
    'Nennel',
    'Tandur',
    'Vemanpalle'
  ],
  'Medak': [
    'Alladurg',
    'Chegunta',
    'Chilipched',
    'Haveli Ghanpur',
    'Kowdipalle',
    'Kulcharam',
    'Manoharabad',
    'Masaipet',
    'Medak',
    'Narsapur',
    'Narsingi',
    'Nizampet',
    'Papannapet',
    'Ramayampet',
    'Regode',
    'Shankarapet (A)',
    'Shankarapet (R)',
    'Shivampet',
    'Tekmal',
    'Toopran',
    'Yeldurthy'
  ],
  'Medchal-Malkajgiri': [
    'Alwal',
    'Bachupally',
    'Balanagar',
    'Gandimaisamma Dundigal',
    'Ghatkesar',
    'Kapra',
    'Keesara (M)',
    'Kukatpally',
    'Malkajgiri',
    'Medchal (M)',
    'Medipally',
    'Muduchinthalapally',
    'Quthbullapur',
    'Shamirpet',
    'Uppal'
  ],
  'Mulugu': [
    'Eturunagaram',
    'Govindaraopet',
    'Kannaigudem',
    'Mangapet',
    'Mulug',
    'Tadvai (Sammakka Sarakka)',
    'Venkatapur',
    'Venkatapuram',
    'Wazeed'
  ],
  'Nagarkurnool': [
    'Achampet',
    'Amrabad',
    'Balmoor',
    'Bijinapally',
    'Charakonda',
    'Kalwakurthy',
    'Kodair',
    'Kollapur',
    'Lingal',
    'Nagarkurnool',
    'Padara',
    'Peddakothapalle',
    'Pentlavelli',
    'Tadoor',
    'Telkapally',
    'Thimmajipet',
    'Uppununthala',
    'Urkonda',
    'Vangoor',
    'Veldanda'
  ],
  'Nalgonda': [
    'Adavidevulapally',
    'Anumula',
    'Chandampeta',
    'Chandur',
    'Chintha Palle',
    'Chityal',
    'Damercherla',
    'Devarakonda',
    'Gattuppal',
    'Gudipally',
    'Gundla Palle',
    'Gurrampode',
    'Kangal',
    'Kattangur',
    'Kethepally',
    'Konda Mallepally',
    'Madugulapally',
    'Marri Guda',
    'Miryalaguda',
    'Munugode',
    'Nakrekal',
    'Nalgonda',
    'Nampally',
    'Narketpalle',
    'Neredugommu',
    'Nidamanur',
    'Peda Adisharla Palli',
    'Peddavoora',
    'Shaligouraram',
    'Tipparthy',
    'Tirumalagiri (Sagar)',
    'Tripuraram',
    'Vemulapally'
  ],
  'Narayanpet': [
    'Damaragidda',
    'Dhanwada',
    'Gundumal',
    'Kosgi',
    'Kothapalle',
    'Krishna',
    'Maddur',
    'Maganoor',
    'Makthal',
    'Marikal',
    'Narayanpet',
    'Narwa',
    'Utkoor'
  ],
  'Nirmal': [
    'Basar',
    'Bhainsa',
    'Dasturabad',
    'Dilawarpur',
    'Kaddam Peddur',
    'Khanapur',
    'Kubeer',
    'Kuntala',
    'Laxmanchanda',
    'Lokeshwaram',
    'Mamada',
    'Mudhole',
    'Narsapur (G)',
    'Nirmal Rural',
    'Nirmal (U)',
    'Pembi',
    'Sarangapur',
    'Soan',
    'Tanur'
  ],
  'Nizamabad': [
    'Aloor',
    'Armoor',
    'Balkonda',
    'Bheemgal',
    'Bodhan',
    'Chandur',
    'Dharpally',
    'Dichpally',
    'Donkeshwar',
    'Indalwai',
    'Jakranpalle',
    'Kammarpally',
    'Kotagiri',
    'Makloor',
    'Mendora',
    'Morthad',
    'Mosra',
    'Mugpal',
    'Mupkal',
    'Nandipet',
    'Navipet',
    'Nizamabad North',
    'Nizamabad Rural',
    'Nizamabad South',
    'Pothangal',
    'Renjal',
    'Rudrur',
    'Saloora',
    'Sirkonda',
    'Vailpoor',
    'Varni',
    'Yedapally',
    'Yergatla'
  ],
  'Peddapalli': [
    'Anthargaon',
    'Dharmaram',
    'Eligaid',
    'Julapalle',
    'Kamanpur',
    'Manthani',
    'Mutharam Manthani',
    'Odela',
    'Palakurthy',
    'Peddapalle',
    'Ramagiri',
    'Ramagundam',
    'Srirampur',
    'Sultanabad'
  ],
  'Rajanna Sircilla': [
    'Boinpalle',
    'Chandurthi',
    'Gambhiraopet',
    'Illanthakunta',
    'Konaraopeta',
    'Mustabad',
    'Rudrangi',
    'Sirsilla',
    'Thangallapalli',
    'Veernapalli',
    'Vemulawada',
    'Vemulawada Rural',
    'Yella Reddi Peta'
  ],
  'Rangareddy': [
    'Abdullapurmet',
    'Amangal',
    'Balapur',
    'Chevella (M)',
    'Farooqnagar',
    'Gandipet',
    'Hayathnagar',
    'Ibrahimpatnam',
    'Jilled Chowdergudem',
    'Kadthal',
    'Kandukur',
    'Keshampeta',
    'Kondurg',
    'Kothur',
    'Madgul',
    'Maheshwaram (M)',
    'Manchal',
    'Moinabad',
    'Nandigama',
    'Rajendranagar',
    'Saroornagar',
    'Serilingampalle',
    'Shabad',
    'Shamshabad',
    'Shankarpalle',
    'Talakondapally',
    'Yacharam'
  ],
  'Sangareddy': [
    'Ameenpur',
    'Andole',
    'Chowtakur',
    'Gummadidala',
    'Hathnoor',
    'Jharasangam',
    'Jinnaram',
    'Kalher',
    'Kandi',
    'Kangti',
    'Kohir',
    'Kondapur',
    'Manoor',
    'Mogudampally',
    'Munipally',
    'Nagalgidda',
    'Narayankhed',
    'Nizampet',
    'Nyalkal',
    'Patancheru',
    'Pulkall',
    'Raikode',
    'Ramachandrapuram',
    'Sadasivpet',
    'Sangareddy',
    'Sirgapoor',
    'Vatpally',
    'Zahirabad'
  ],
  'Siddipet': [
    'Akbarpet-Bhoompally',
    'Akkannapet',
    'Bejjanki',
    'Cheriyal',
    'Chinnakodur',
    'Dhoolmitta',
    'Doultabad',
    'Dubbak',
    'Gajwel',
    'Husnabad',
    'Jagdevpur',
    'Koheda',
    'Komuravelli',
    'Kondapak',
    'Kuknoorpally',
    'Maddur',
    'Markook',
    'Mirdoddi',
    'Mulug',
    'Nanganoor',
    'Narayanraopet',
    'Raipole',
    'Siddipet Rural',
    'Siddipet Urban',
    'Thoguta',
    'Wargal'
  ],
  'Suryapet': [
    'Ananthagiri',
    'Athmakur (S)',
    'Chilkur',
    'Chinthalapalem (Mallareddygudem)',
    'Chivvemla',
    'Garide Palle',
    'Huzurnagar',
    'Jajireddy Gudem',
    'Kodad',
    'Maddirala',
    'Mattampalle',
    'Mellacheruvu',
    'Mothey',
    'Munagala',
    'Nadigudem',
    'Nagaram',
    'Nereducherla',
    'Noothanakal',
    'Palakeedu',
    'Penpahad',
    'Suryapet',
    'Thirumalagiri',
    'Thungathurthy'
  ],
  'Vikarabad': [
    'Bantwaram',
    'Basheerabad',
    'Bomraspet',
    'Chowdapur',
    'Dharur',
    'Doma',
    'Doulatabad',
    'Dudyal',
    'Kodangal',
    'Kotepally',
    'Kulkacharla',
    'Marpalle',
    'Mominpet',
    'Nawabpet',
    'Pargi',
    'Peddemul',
    'Pudur',
    'Tandur',
    'Vikarabad',
    'Yelal'
  ],
  'Wanaparthy': [
    'Amarchintha',
    'Atmakur',
    'Chinnambavi',
    'Ghanpur',
    'Gopalpet',
    'Kothakota',
    'Madanapur',
    'Pangal',
    'Pebbair',
    'Peddamandadi',
    'Revally',
    'Srirangapur',
    'Wanaparthy',
    'Weepanagandla',
    'Yedula'
  ],
  'Warangal': [
    'Chennaraopet',
    'Duggondi',
    'Geesugonda',
    'Khanapur',
    'Khila Warangal',
    'Nallabelly',
    'Narsampet',
    'Nekkonda',
    'Parvathagiri',
    'Raiparthy',
    'Sangem',
    'Warangal',
    'Wardhannapet'
  ],
  'Yadadri Bhuvanagiri': [
    'Addagudur',
    'Alair',
    'Athmakur (M)',
    'Bhongir',
    'Bibinagar',
    'Bommalaramaram',
    'B.Pochampally',
    'Choutuppal',
    'Gundala',
    'Motakondur',
    'Mothkur',
    'Narayanapoor',
    'Rajapet',
    'Ramannapeta',
    'Thurkapally',
    'Valigonda',
    'Yadagirigutta'
  ]
};

// // Example data structure for districts, mandals, and villages
// const districtData = {
//   'Adilabad': {
//     'Mandal1': ['Village1', 'Village2'],
//   },
//   'Bhadradri Kothagudem': {
//     'Mandal2': ['Village3', 'Village4'],
//   },
//   'Hanumakonda': {
//     'Mandal3': ['Village5', 'Village6'],
//   },
//   'Jagtial': {
//     'Mandal4': ['Village7', 'Village8'],
//   },
//   'Jangaon': {
//     'Mandal5': ['Village9', 'Village10'],
//   },
//   'Jayashankar Bhupalpalli': {
//     'Mandal6': ['Village11', 'Village12'],
//   },
//   'Jogulamba Gadwal': {
//     'Mandal7': ['Village13', 'Village14'],
//   },
//   'Kamareddy': {
//     'Mandal8': ['Village15', 'Village16'],
//   },
//   'Karimnagar': {
//     'Mandal9': ['Village17', 'Village18'],
//   },
//   'Khammam': {
//     'Mandal10': ['Village19', 'Village20'],
//   },
//   'Kumuram Bheem (Asifabad)': {
//     'Mandal11': ['Village21', 'Village22'],
//   },
//   'Mahabubabad': {
//     'Mandal12': ['Village23', 'Village24'],
//   },
//   'Mahabubnagar': {
//     'Mandal13': ['Village25', 'Village26'],
//   },
//   'Mancherial': {
//     'Mandal14': ['Village27', 'Village28'],
//   },
//   'Medak': {
//     'Mandal15': ['Village29', 'Village30'],
//   },
//   'Medchal-Malkajgiri': {
//     'Mandal16': ['Village31', 'Village32'],
//   },
//   'Mulugu': {
//     'Mandal17': ['Village33', 'Village34'],
//   },
//   'Nagarkurnool': {
//     'Mandal18': ['Village35', 'Village36'],
//   },
//   'Nalgonda': {
//     'Mandal19': ['Village37', 'Village38'],
//   },
//   'Narayanpet': {
//     'Mandal20': ['Village39', 'Village40'],
//   },
//   'Nirmal': {
//     'Mandal21': ['Village41', 'Village42'],
//   },
//   'Nizamabad': {
//     'Mandal22': ['Village43', 'Village44'],
//   },
//   'Peddapalli': {
//     'Mandal23': ['Village45', 'Village46'],
//   },
//   'Rajanna Sircilla': {
//     'Mandal24': ['Village47', 'Village48'],
//   },
//   'Rangareddy': {
//     'Mandal25': ['Village49', 'Village50'],
//   },
//   'Sangareddy': {
//     'Mandal26': ['Village51', 'Village52'],
//   },
//   'Siddipet': {
//     'Mandal27': ['Village53', 'Village54'],
//   },
//   'Suryapet': {
//     'Mandal28': ['Village55', 'Village56'],
//   },
//   'Vikarabad': {
//     'Mandal29': ['Village57', 'Village58'],
//   },
//   'Wanaparthy': {
//     'Mandal30': ['Village59', 'Village60'],
//   },
//   'Warangal': {
//     'Mandal31': ['Village61', 'Village62'],
//   },
//   'Yadadri Bhuvanagiri': {
//     'Mandal32': ['Village63', 'Village64'],
//   }
// };
