
import 'package:flutter/material.dart';

/* Стандартные иконки https://fonts.google.com/icons?selected=Material+Icons */

class Funtya {
  /*
  Usage:
    Icon(Funtya.all24hours),
    Icon(Funtya.all360degrees),
  */

  Funtya._();

  static const defaultIcon = Icons.insert_emoticon;

  static const _kFontFam = 'Funtya';
  static const String? _kFontPkg = null;
  /* DEMO:
  static const IconData all24hours = IconData(0x41, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData all360degrees = IconData(0x42, fontFamily: _kFontFam, fontPackage: _kFontPkg);

  static Icon getIcon(String iconName) {
    Icon result = defaultIcon;
    if (iconName == 'all24hours') {
      result = Icon(all24hours);
    } else if (iconName == 'all3all360degrees') {
      result = Icon(all360degrees);
    }
    return result;
  }
  */

  /* DEMO2:
  static const IconData passport = IconData(0x370, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData cleaning = IconData(0x901, fontFamily: _kFontFam, fontPackage: _kFontPkg);

  static const Map<String, Icon> icons = {
    'passport': Icon(passport),
    'cleaning': Icon(cleaning),
  };

  static Icon getIcon(String iconName) {
    return icons[iconName] != null ? icons[iconName] : defaultIcon;
  }
  */
  static IconData getIcon(String iconName) {
    IconData? result = icons[iconName];
    return result ?? defaultIcon;
  }

  static const IconData passport = IconData(0x370, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData blood = IconData(0x371, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData grocery_stores = IconData(0x372, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData oncologist = IconData(0x373, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData straw2 = IconData(0x374, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData solarium = IconData(0x375, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData amusement_park = IconData(0x376, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData meat = IconData(0x377, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData investment = IconData(0x378, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData conference = IconData(0x379, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData sport = IconData(0x380, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData law23 = IconData(0x381, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData roller_skate = IconData(0x382, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData hunting = IconData(0x383, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData socials = IconData(0x384, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData varicose_veins = IconData(0x385, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData bee = IconData(0x386, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData equipment = IconData(0x387, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData cargo_ship = IconData(0x388, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData beverages = IconData(0x389, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData straw = IconData(0x390, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData allergy = IconData(0x391, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData plastic_surgery = IconData(0x392, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData carwash = IconData(0x393, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData hydro_power = IconData(0x394, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData jeans = IconData(0x395, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData sauna = IconData(0x396, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData virus = IconData(0x397, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData house = IconData(0x398, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData bed = IconData(0x399, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData bathroom = IconData(0x400, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData body_massage = IconData(0x401, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData emergency_call = IconData(0x402, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData eggs = IconData(0x403, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData surgeon = IconData(0x404, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData bean_bag = IconData(0x405, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData sex = IconData(0x406, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData lesson = IconData(0x407, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData steering_wheel = IconData(0x408, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData stool = IconData(0x409, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData information = IconData(0x410, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData physical_education = IconData(0x411, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData tools = IconData(0x412, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData section = IconData(0x413, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData electrical_appliance = IconData(0x414, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData sugar_cube = IconData(0x415, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData olive_oil = IconData(0x416, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData deal = IconData(0x417, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData music_equipment = IconData(0x418, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData emergency = IconData(0x419, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData medicine = IconData(0x420, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData fishing = IconData(0x421, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData safety = IconData(0x422, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData carservice = IconData(0x423, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData spices = IconData(0x424, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData beer = IconData(0x425, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData kidneys = IconData(0x426, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData translate = IconData(0x427, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData chopshop = IconData(0x428, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData disabled_people = IconData(0x429, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData cmyk = IconData(0x430, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData butterfly = IconData(0x431, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData umbrella = IconData(0x432, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData optical = IconData(0x433, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData butter = IconData(0x434, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData car_parts = IconData(0x435, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData gym = IconData(0x436, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData food_delivery = IconData(0x437, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData restaurant = IconData(0x438, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData car_alarm = IconData(0x439, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData ideas = IconData(0x440, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData high_heels = IconData(0x441, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData barbel = IconData(0x442, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData shark = IconData(0x443, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData healthcare = IconData(0x444, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData smartphone = IconData(0x445, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData builder = IconData(0x446, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData tire_workshops = IconData(0x447, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData inflatable_castle = IconData(0x448, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData running_horse_with_racer_and_saddle_outline = IconData(0x449, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData drugs = IconData(0x450, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData color_palette = IconData(0x451, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData pulmonology = IconData(0x452, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData attic = IconData(0x453, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData chemistry = IconData(0x455, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData ticket2 = IconData(0x456, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData cupboard = IconData(0x457, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData goods = IconData(0x458, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData ticket = IconData(0x459, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData baby_shoes = IconData(0x460, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData trucking = IconData(0x461, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData atm_machine = IconData(0x462, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData red_blood_cells = IconData(0x463, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData lease = IconData(0x464, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData policeman = IconData(0x465, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData parking_short = IconData(0x466, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData lawn_mower = IconData(0x467, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData notary = IconData(0x468, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData liver = IconData(0x469, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData dry_cleaning = IconData(0x470, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData dental_implant = IconData(0x471, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData pay_per_click = IconData(0x472, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData lenins_mausoleum = IconData(0x473, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData coffee_machine = IconData(0x474, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData bunny = IconData(0x475, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData services = IconData(0x476, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData pet_brush = IconData(0x477, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData books = IconData(0x478, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData swimmer = IconData(0x479, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData bike = IconData(0x480, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData piercing = IconData(0x481, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData blood_bag = IconData(0x482, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData breast_cancer = IconData(0x483, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData motorbike = IconData(0x484, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData car_repair2 = IconData(0x485, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData car_repair3 = IconData(0x486, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData electric_car = IconData(0x487, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData parking2 = IconData(0x488, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData lego = IconData(0x489, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData service = IconData(0x490, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData household_goods = IconData(0x491, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData b2b = IconData(0x492, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData child_garden = IconData(0x493, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData diabetes_test = IconData(0x494, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData parking_sign = IconData(0x495, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData waterdrop = IconData(0x496, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData pedicure = IconData(0x497, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData analyzes = IconData(0x498, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData business_stationery = IconData(0x499, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData ruble = IconData(0x500, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData collector = IconData(0x501, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData paint_roller = IconData(0x502, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData kidney = IconData(0x503, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData hospital2 = IconData(0x504, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData video_stream = IconData(0x505, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData cigarette = IconData(0x506, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData simulation = IconData(0x507, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData christmas_tree = IconData(0x508, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData trouser = IconData(0x509, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData shopping_bag = IconData(0x511, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData safe_deposit = IconData(0x512, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData gasoline_station = IconData(0x513, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData curtain = IconData(0x514, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData darth_vader = IconData(0x515, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData cafe = IconData(0x516, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData massage = IconData(0x517, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData approved = IconData(0x518, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData mover = IconData(0x519, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData examination2 = IconData(0x520, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData eye_test = IconData(0x521, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData clipboard = IconData(0x522, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData dolphin = IconData(0x523, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData fertilizer = IconData(0x524, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData gas_bottle = IconData(0x525, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData money_transfer = IconData(0x526, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData certificate = IconData(0x527, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData office_chair = IconData(0x528, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData body_repair = IconData(0x529, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData crib = IconData(0x530, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData appartments = IconData(0x531, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData car_glass = IconData(0x532, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData flowers = IconData(0x533, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData antenna = IconData(0x534, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData hospital3 = IconData(0x535, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData manual_transmission = IconData(0x536, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData telescope = IconData(0x537, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData hubcap = IconData(0x538, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData rehabilitation = IconData(0x539, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData ship = IconData(0x540, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData wallpaper = IconData(0x541, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData steam_cocktails = IconData(0x542, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData senate = IconData(0x543, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData skating = IconData(0x544, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData subwoofer = IconData(0x545, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData morgue = IconData(0x546, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData bread = IconData(0x547, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData fueleb = IconData(0x548, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData vote = IconData(0x549, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData seat = IconData(0x550, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData automatisation = IconData(0x551, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData turbo_engine = IconData(0x552, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData archive = IconData(0x553, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData coworking = IconData(0x554, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData dog2 = IconData(0x555, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData school = IconData(0x556, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData cinema = IconData(0x557, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData services2 = IconData(0x558, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData servers = IconData(0x559, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData soldier = IconData(0x560, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData gallery = IconData(0x561, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData greenhouse = IconData(0x562, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData neurosurgeon = IconData(0x563, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData car_painting = IconData(0x564, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData satellite = IconData(0x565, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData biometric = IconData(0x566, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData no_smoking = IconData(0x567, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData industrial = IconData(0x568, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData sewing_machine = IconData(0x569, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData dna = IconData(0x570, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData house_hold = IconData(0x571, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData radio = IconData(0x572, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData taxi = IconData(0x573, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData shelter = IconData(0x574, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData train = IconData(0x575, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData toll_road = IconData(0x576, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData stationery = IconData(0x577, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData drilling_rig = IconData(0x578, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData polygraphy = IconData(0x579, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData cake = IconData(0x580, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData manicure = IconData(0x581, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData sweetshop = IconData(0x582, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData aquapark = IconData(0x583, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData exchange = IconData(0x584, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData stadiums = IconData(0x585, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData battery = IconData(0x586, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData immunity = IconData(0x587, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData beauty_salons = IconData(0x588, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData car_trailer = IconData(0x589, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData newspaper = IconData(0x590, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData carpet = IconData(0x591, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData snowflake = IconData(0x592, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData circus_tent = IconData(0x593, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData advertisment = IconData(0x594, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData diagnostic = IconData(0x595, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData clothes = IconData(0x596, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData booking = IconData(0x597, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData billiard = IconData(0x598, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData container = IconData(0x599, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData repair_parts = IconData(0x600, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData turtle = IconData(0x601, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData registry_office = IconData(0x602, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData fur_coat = IconData(0x603, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData appliances = IconData(0x604, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData paper = IconData(0x605, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData orthopedist = IconData(0x606, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData lottery = IconData(0x607, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData trophy = IconData(0x608, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData magician_hat = IconData(0x609, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData voice_control = IconData(0x610, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData ranking = IconData(0x611, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData garbage_truck = IconData(0x612, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData jewelry = IconData(0x613, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData quest = IconData(0x614, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData tent = IconData(0x615, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData hospital = IconData(0x616, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData aids = IconData(0x617, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData auto = IconData(0x618, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData mushroom = IconData(0x619, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData cells = IconData(0x620, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData phone_set = IconData(0x621, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData sunbed = IconData(0x622, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData watch = IconData(0x623, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData baby_clothes = IconData(0x624, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData internet = IconData(0x625, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData scale = IconData(0x626, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData canned_food = IconData(0x627, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData milk_bottle = IconData(0x628, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData pendant = IconData(0x629, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData vaccine = IconData(0x630, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData closed_eyes_with_lashes_and_brows = IconData(0x631, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData dog = IconData(0x632, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData veterinary = IconData(0x633, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData table_games = IconData(0x634, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData oil = IconData(0x635, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData business_center = IconData(0x636, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData stomach = IconData(0x637, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData cocktail_dress = IconData(0x638, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData storm = IconData(0x639, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData doors = IconData(0x640, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData footwear = IconData(0x641, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData pregnant = IconData(0x642, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData lottery2 = IconData(0x643, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData watch_tv = IconData(0x644, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData fitnes = IconData(0x645, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData virtual_reality_glasses = IconData(0x646, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData all360degree = IconData(0x647, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData fish = IconData(0x648, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData gold = IconData(0x649, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData mental_health = IconData(0x650, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData repair = IconData(0x651, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData burger = IconData(0x652, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData derby = IconData(0x653, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData coins = IconData(0x654, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData rocking_horse = IconData(0x655, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData real_estate_agent = IconData(0x656, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData padlock = IconData(0x657, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData matryoshka = IconData(0x658, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData coding = IconData(0x659, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData metal_detector = IconData(0x660, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData garage = IconData(0x661, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData textiles = IconData(0x662, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData child = IconData(0x663, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData lymph_nodes = IconData(0x664, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData ink_cartridge = IconData(0x665, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData furniture = IconData(0x666, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData injection = IconData(0x667, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData culture = IconData(0x668, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData dancer = IconData(0x669, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData down_jacket = IconData(0x670, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData razor = IconData(0x671, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData animal_shelter = IconData(0x672, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData fork = IconData(0x673, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData client = IconData(0x674, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData kremlin = IconData(0x675, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData excavator = IconData(0x676, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData finances = IconData(0x677, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData all24hours = IconData(0x678, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData camera_drone = IconData(0x679, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData sales_equip = IconData(0x680, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData vet = IconData(0x681, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData police = IconData(0x682, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData audiologist = IconData(0x683, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData noodles = IconData(0x684, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData box = IconData(0x685, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData uniform = IconData(0x686, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData rake = IconData(0x687, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData stethoscope = IconData(0x688, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData classroom = IconData(0x689, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData maid = IconData(0x690, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData seeds = IconData(0x691, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData bush = IconData(0x692, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData bar = IconData(0x693, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData profession = IconData(0x694, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData malls = IconData(0x695, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData radiation = IconData(0x696, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData speaker = IconData(0x697, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData baby = IconData(0x698, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData camera = IconData(0x699, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData printer = IconData(0x700, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData souvenir = IconData(0x701, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData color_palette2 = IconData(0x702, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData hay = IconData(0x703, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData overtime = IconData(0x704, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData truck = IconData(0x705, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData love = IconData(0x706, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData dentistry = IconData(0x707, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData aromatic = IconData(0x708, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData voice = IconData(0x709, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData feeding_bottle = IconData(0x710, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData housing = IconData(0x711, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData vinyl = IconData(0x712, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData glass = IconData(0x713, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData engineer = IconData(0x714, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData intestine = IconData(0x715, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData bus = IconData(0x716, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData rope = IconData(0x717, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData fireman = IconData(0x718, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData livingroom = IconData(0x719, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData estate = IconData(0x720, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData infinity = IconData(0x721, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData check_list = IconData(0x722, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData almond = IconData(0x723, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData provider = IconData(0x724, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData gazebo = IconData(0x725, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData lip_balm = IconData(0x726, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData toilet = IconData(0x727, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData market = IconData(0x728, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData diving_mask = IconData(0x729, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData marble = IconData(0x730, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData rent_sign = IconData(0x731, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData building_renovation = IconData(0x732, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData truck2 = IconData(0x733, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData guitar = IconData(0x734, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData lawyer2 = IconData(0x735, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData epilation = IconData(0x736, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData fireproof = IconData(0x737, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData tiles = IconData(0x738, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData fireproof2 = IconData(0x739, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData bases = IconData(0x740, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData kitchen = IconData(0x741, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData engineering = IconData(0x742, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData metall = IconData(0x743, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData packaging = IconData(0x744, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData sim_toolkit = IconData(0x745, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData dop_obrazovan = IconData(0x746, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData anchor = IconData(0x747, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData dish = IconData(0x748, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData tinted_glass = IconData(0x749, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData government = IconData(0x750, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData tiles2 = IconData(0x751, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData windows = IconData(0x752, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData hirudotherapy = IconData(0x753, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData plot = IconData(0x754, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData chiropractic = IconData(0x755, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData education = IconData(0x756, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData pipe = IconData(0x757, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData household = IconData(0x758, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData fruit = IconData(0x759, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData surf = IconData(0x760, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData sakura = IconData(0x761, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData life_insurance = IconData(0x762, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData soybean = IconData(0x763, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData car_repair = IconData(0x764, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData knife = IconData(0x765, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData services_equip = IconData(0x766, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData boomerang_stick = IconData(0x767, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData pharmacy = IconData(0x768, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData medical_goods = IconData(0x769, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData creativity = IconData(0x770, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData butterfly2 = IconData(0x771, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData valenki = IconData(0x772, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData bank = IconData(0x773, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData reading_eyeglasses = IconData(0x774, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData warehouse = IconData(0x775, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData frame = IconData(0x776, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData judge = IconData(0x777, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData joint = IconData(0x778, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData home_cinema = IconData(0x779, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData government2 = IconData(0x780, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData carburetor = IconData(0x781, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData computer = IconData(0x782, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData hot = IconData(0x783, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData hairdressers = IconData(0x784, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData acupuncture = IconData(0x785, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData tires = IconData(0x786, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData bed_sheets = IconData(0x787, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData reflector = IconData(0x788, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData sketch = IconData(0x789, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData mobile_phone = IconData(0x790, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData duck_shooting = IconData(0x791, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData development = IconData(0x792, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData nachos = IconData(0x793, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData search_engine = IconData(0x794, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData bankruptcy = IconData(0x795, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData phone = IconData(0x796, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData protection = IconData(0x797, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData no_virus = IconData(0x798, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData smoke = IconData(0x799, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData match = IconData(0x800, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData announcement = IconData(0x801, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData tractor = IconData(0x802, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData face_scanner = IconData(0x803, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData signboard = IconData(0x804, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData reflex_hammer = IconData(0x805, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData funicular = IconData(0x806, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData hair_transplant = IconData(0x807, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData eat = IconData(0x808, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData mortgage = IconData(0x809, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData pest_control = IconData(0x810, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData polling_place = IconData(0x811, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData face_of_a_woman_outline = IconData(0x812, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData thunderbolt = IconData(0x813, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData embroidery = IconData(0x814, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData therapist = IconData(0x815, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData growth = IconData(0x816, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData tourism = IconData(0x817, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData military_hat = IconData(0x818, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData skate_park = IconData(0x819, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData toothpaste = IconData(0x820, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData aquarium = IconData(0x821, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData fabric = IconData(0x822, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData tree = IconData(0x823, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData id_card = IconData(0x824, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData noise = IconData(0x825, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData hotels = IconData(0x826, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData key_chain = IconData(0x827, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData dishes = IconData(0x828, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData express_mail = IconData(0x829, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData cosmetics = IconData(0x830, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData calendar = IconData(0x831, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData license_plate = IconData(0x832, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData sausage = IconData(0x833, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData renovation = IconData(0x834, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData lotion = IconData(0x835, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData carbon_dioxide = IconData(0x836, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData customs = IconData(0x837, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData geriatrics = IconData(0x838, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData pets = IconData(0x839, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData couple_with_daughter_in_a_heart = IconData(0x840, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData zoo = IconData(0x841, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData examination = IconData(0x842, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData communication = IconData(0x843, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData electronic_cigarette = IconData(0x844, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData pension = IconData(0x845, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData glue = IconData(0x846, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData nutritionist = IconData(0x847, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData pharmacies = IconData(0x848, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData literature = IconData(0x849, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData dermatology = IconData(0x850, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData cheese = IconData(0x851, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData chair = IconData(0x852, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData ATV = IconData(0x853, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData console = IconData(0x854, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData compact_disk = IconData(0x855, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData employee = IconData(0x856, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData transport = IconData(0x857, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData suitcases = IconData(0x858, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData canal = IconData(0x859, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData wig = IconData(0x860, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData airbrush = IconData(0x861, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData ear = IconData(0x862, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData flame = IconData(0x863, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData grocery = IconData(0x864, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData atom = IconData(0x865, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData other = IconData(0x866, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData ice_cream = IconData(0x867, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData sport_goods = IconData(0x868, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData bowling_pin = IconData(0x869, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData parking = IconData(0x870, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData psychology = IconData(0x871, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData lawyer = IconData(0x872, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData shops = IconData(0x873, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData hostels = IconData(0x874, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData souvenirs = IconData(0x875, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData shopping_cart = IconData(0x876, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData airplane = IconData(0x877, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData spa = IconData(0x878, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData automotive = IconData(0x879, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData female = IconData(0x880, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData ski = IconData(0x881, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData baby_dummy = IconData(0x882, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData plumbing = IconData(0x883, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData mirror = IconData(0x884, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData building = IconData(0x885, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData headlight = IconData(0x886, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData celebration = IconData(0x887, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData history = IconData(0x888, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData gavel = IconData(0x889, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData rack = IconData(0x890, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData tow_truck = IconData(0x891, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData med_center = IconData(0x892, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData garbage = IconData(0x893, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData tuning = IconData(0x894, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData roof = IconData(0x895, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData diving_goggles = IconData(0x896, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData swimming_pool = IconData(0x897, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData comic = IconData(0x898, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData water_cooler = IconData(0x899, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData karaoke = IconData(0x900, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData cleaning = IconData(0x901, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const Map<String, IconData> icons = {

    'passport': passport,
    'blood': blood,
    'grocery_stores': grocery_stores,
    'oncologist': oncologist,
    'straw2': straw2,
    'solarium': solarium,
    'amusement_park': amusement_park,
    'meat': meat,
    'investment': investment,
    'conference': conference,
    'sport': sport,
    'law23': law23,
    'roller_skate': roller_skate,
    'hunting': hunting,
    'socials': socials,
    'varicose_veins': varicose_veins,
    'bee': bee,
    'equipment': equipment,
    'cargo_ship': cargo_ship,
    'beverages': beverages,
    'straw': straw,
    'allergy': allergy,
    'plastic_surgery': plastic_surgery,
    'carwash': carwash,
    'hydro_power': hydro_power,
    'jeans': jeans,
    'sauna': sauna,
    'virus': virus,
    'house': house,
    'bed': bed,
    'bathroom': bathroom,
    'body_massage': body_massage,
    'emergency_call': emergency_call,
    'eggs': eggs,
    'surgeon': surgeon,
    'bean_bag': bean_bag,
    'sex': sex,
    'lesson': lesson,
    'steering_wheel': steering_wheel,
    'stool': stool,
    'information': information,
    'physical_education': physical_education,
    'tools': tools,
    'section': section,
    'electrical_appliance': electrical_appliance,
    'sugar_cube': sugar_cube,
    'olive_oil': olive_oil,
    'deal': deal,
    'music_equipment': music_equipment,
    'emergency': emergency,
    'medicine': medicine,
    'fishing': fishing,
    'safety': safety,
    'carservice': carservice,
    'spices': spices,
    'beer': beer,
    'kidneys': kidneys,
    'translate': translate,
    'chopshop': chopshop,
    'disabled_people': disabled_people,
    'cmyk': cmyk,
    'butterfly': butterfly,
    'umbrella': umbrella,
    'optical': optical,
    'butter': butter,
    'car_parts': car_parts,
    'gym': gym,
    'food_delivery': food_delivery,
    'restaurant': restaurant,
    'car_alarm': car_alarm,
    'ideas': ideas,
    'high_heels': high_heels,
    'barbel': barbel,
    'shark': shark,
    'healthcare': healthcare,
    'smartphone': smartphone,
    'builder': builder,
    'tire_workshops': tire_workshops,
    'inflatable_castle': inflatable_castle,
    'running_horse_with_racer_and_saddle_outline': running_horse_with_racer_and_saddle_outline,
    'drugs': drugs,
    'color_palette': color_palette,
    'pulmonology': pulmonology,
    'attic': attic,
    'chemistry': chemistry,
    'ticket2': ticket2,
    'cupboard': cupboard,
    'goods': goods,
    'ticket': ticket,
    'baby_shoes': baby_shoes,
    'trucking': trucking,
    'atm_machine': atm_machine,
    'red_blood_cells': red_blood_cells,
    'lease': lease,
    'policeman': policeman,
    'parking_short': parking_short,
    'lawn_mower': lawn_mower,
    'notary': notary,
    'liver': liver,
    'dry_cleaning': dry_cleaning,
    'dental_implant': dental_implant,
    'pay_per_click': pay_per_click,
    'lenins_mausoleum': lenins_mausoleum,
    'coffee_machine': coffee_machine,
    'bunny': bunny,
    'services': services,
    'pet_brush': pet_brush,
    'books': books,
    'swimmer': swimmer,
    'bike': bike,
    'piercing': piercing,
    'blood_bag': blood_bag,
    'breast_cancer': breast_cancer,
    'motorbike': motorbike,
    'car_repair2': car_repair2,
    'car_repair3': car_repair3,
    'electric_car': electric_car,
    'parking2': parking2,
    'lego': lego,
    'service': service,
    'household_goods': household_goods,
    'b2b': b2b,
    'child_garden': child_garden,
    'diabetes_test': diabetes_test,
    'parking_sign': parking_sign,
    'waterdrop': waterdrop,
    'pedicure': pedicure,
    'analyzes': analyzes,
    'business_stationery': business_stationery,
    'ruble': ruble,
    'collector': collector,
    'paint_roller': paint_roller,
    'kidney': kidney,
    'hospital2': hospital2,
    'video_stream': video_stream,
    'cigarette': cigarette,
    'simulation': simulation,
    'christmas_tree': christmas_tree,
    'trouser': trouser,
    'shopping_bag': shopping_bag,
    'safe_deposit': safe_deposit,
    'gasoline_station': gasoline_station,
    'curtain': curtain,
    'darth_vader': darth_vader,
    'cafe': cafe,
    'massage': massage,
    'approved': approved,
    'mover': mover,
    'examination2': examination2,
    'eye_test': eye_test,
    'clipboard': clipboard,
    'dolphin': dolphin,
    'fertilizer': fertilizer,
    'gas_bottle': gas_bottle,
    'money_transfer': money_transfer,
    'certificate': certificate,
    'office_chair': office_chair,
    'body_repair': body_repair,
    'crib': crib,
    'appartments': appartments,
    'car_glass': car_glass,
    'flowers': flowers,
    'antenna': antenna,
    'hospital3': hospital3,
    'manual_transmission': manual_transmission,
    'telescope': telescope,
    'hubcap': hubcap,
    'rehabilitation': rehabilitation,
    'ship': ship,
    'wallpaper': wallpaper,
    'steam_cocktails': steam_cocktails,
    'senate': senate,
    'skating': skating,
    'subwoofer': subwoofer,
    'morgue': morgue,
    'bread': bread,
    'fueleb': fueleb,
    'vote': vote,
    'seat': seat,
    'automatisation': automatisation,
    'turbo_engine': turbo_engine,
    'archive': archive,
    'coworking': coworking,
    'dog2': dog2,
    'school': school,
    'cinema': cinema,
    'services2': services2,
    'servers': servers,
    'soldier': soldier,
    'gallery': gallery,
    'greenhouse': greenhouse,
    'neurosurgeon': neurosurgeon,
    'car_painting': car_painting,
    'satellite': satellite,
    'biometric': biometric,
    'no_smoking': no_smoking,
    'industrial': industrial,
    'sewing_machine': sewing_machine,
    'dna': dna,
    'house_hold': house_hold,
    'radio': radio,
    'taxi': taxi,
    'shelter': shelter,
    'train': train,
    'toll_road': toll_road,
    'stationery': stationery,
    'drilling_rig': drilling_rig,
    'polygraphy': polygraphy,
    'cake': cake,
    'manicure': manicure,
    'sweetshop': sweetshop,
    'aquapark': aquapark,
    'exchange': exchange,
    'stadiums': stadiums,
    'battery': battery,
    'immunity': immunity,
    'beauty_salons': beauty_salons,
    'car_trailer': car_trailer,
    'newspaper': newspaper,
    'carpet': carpet,
    'snowflake': snowflake,
    'circus_tent': circus_tent,
    'advertisment': advertisment,
    'diagnostic': diagnostic,
    'clothes': clothes,
    'booking': booking,
    'billiard': billiard,
    'container': container,
    'repair_parts': repair_parts,
    'turtle': turtle,
    'registry_office': registry_office,
    'fur_coat': fur_coat,
    'appliances': appliances,
    'paper': paper,
    'orthopedist': orthopedist,
    'lottery': lottery,
    'trophy': trophy,
    'magician_hat': magician_hat,
    'voice_control': voice_control,
    'ranking': ranking,
    'garbage_truck': garbage_truck,
    'jewelry': jewelry,
    'quest': quest,
    'tent': tent,
    'hospital': hospital,
    'aids': aids,
    'auto': auto,
    'mushroom': mushroom,
    'cells': cells,
    'phone_set': phone_set,
    'sunbed': sunbed,
    'watch': watch,
    'baby_clothes': baby_clothes,
    'internet': internet,
    'scale': scale,
    'canned_food': canned_food,
    'milk_bottle': milk_bottle,
    'pendant': pendant,
    'vaccine': vaccine,
    'closed_eyes_with_lashes_and_brows': closed_eyes_with_lashes_and_brows,
    'dog': dog,
    'veterinary': veterinary,
    'table_games': table_games,
    'oil': oil,
    'business_center': business_center,
    'stomach': stomach,
    'cocktail_dress': cocktail_dress,
    'storm': storm,
    'doors': doors,
    'footwear': footwear,
    'pregnant': pregnant,
    'lottery2': lottery2,
    'watch_tv': watch_tv,
    'fitnes': fitnes,
    'virtual_reality_glasses': virtual_reality_glasses,
    'all360degree': all360degree,
    'fish': fish,
    'gold': gold,
    'mental_health': mental_health,
    'repair': repair,
    'burger': burger,
    'derby': derby,
    'coins': coins,
    'rocking_horse': rocking_horse,
    'real_estate_agent': real_estate_agent,
    'padlock': padlock,
    'matryoshka': matryoshka,
    'coding': coding,
    'metal_detector': metal_detector,
    'garage': garage,
    'textiles': textiles,
    'child': child,
    'lymph_nodes': lymph_nodes,
    'ink_cartridge': ink_cartridge,
    'furniture': furniture,
    'injection': injection,
    'culture': culture,
    'dancer': dancer,
    'down_jacket': down_jacket,
    'razor': razor,
    'animal_shelter': animal_shelter,
    'fork': fork,
    'client': client,
    'kremlin': kremlin,
    'excavator': excavator,
    'finances': finances,
    'all24hours': all24hours,
    'camera_drone': camera_drone,
    'sales_equip': sales_equip,
    'vet': vet,
    'police': police,
    'audiologist': audiologist,
    'noodles': noodles,
    'box': box,
    'uniform': uniform,
    'rake': rake,
    'stethoscope': stethoscope,
    'classroom': classroom,
    'maid': maid,
    'seeds': seeds,
    'bush': bush,
    'bar': bar,
    'profession': profession,
    'malls': malls,
    'radiation': radiation,
    'speaker': speaker,
    'baby': baby,
    'camera': camera,
    'printer': printer,
    'souvenir': souvenir,
    'color_palette2': color_palette2,
    'hay': hay,
    'overtime': overtime,
    'truck': truck,
    'love': love,
    'dentistry': dentistry,
    'aromatic': aromatic,
    'voice': voice,
    'feeding_bottle': feeding_bottle,
    'housing': housing,
    'vinyl': vinyl,
    'glass': glass,
    'engineer': engineer,
    'intestine': intestine,
    'bus': bus,
    'rope': rope,
    'fireman': fireman,
    'livingroom': livingroom,
    'estate': estate,
    'infinity': infinity,
    'check_list': check_list,
    'almond': almond,
    'provider': provider,
    'gazebo': gazebo,
    'lip_balm': lip_balm,
    'toilet': toilet,
    'market': market,
    'diving_mask': diving_mask,
    'marble': marble,
    'rent_sign': rent_sign,
    'building_renovation': building_renovation,
    'truck2': truck2,
    'guitar': guitar,
    'lawyer2': lawyer2,
    'epilation': epilation,
    'fireproof': fireproof,
    'tiles': tiles,
    'fireproof2': fireproof2,
    'bases': bases,
    'kitchen': kitchen,
    'engineering': engineering,
    'metall': metall,
    'packaging': packaging,
    'sim_toolkit': sim_toolkit,
    'dop_obrazovan': dop_obrazovan,
    'anchor': anchor,
    'dish': dish,
    'tinted_glass': tinted_glass,
    'government': government,
    'tiles2': tiles2,
    'windows': windows,
    'hirudotherapy': hirudotherapy,
    'plot': plot,
    'chiropractic': chiropractic,
    'education': education,
    'pipe': pipe,
    'household': household,
    'fruit': fruit,
    'surf': surf,
    'sakura': sakura,
    'life_insurance': life_insurance,
    'soybean': soybean,
    'car_repair': car_repair,
    'knife': knife,
    'services_equip': services_equip,
    'boomerang_stick': boomerang_stick,
    'pharmacy': pharmacy,
    'medical_goods': medical_goods,
    'creativity': creativity,
    'butterfly2': butterfly2,
    'valenki': valenki,
    'bank': bank,
    'reading_eyeglasses': reading_eyeglasses,
    'warehouse': warehouse,
    'frame': frame,
    'judge': judge,
    'joint': joint,
    'home_cinema': home_cinema,
    'government2': government2,
    'carburetor': carburetor,
    'computer': computer,
    'hot': hot,
    'hairdressers': hairdressers,
    'acupuncture': acupuncture,
    'tires': tires,
    'bed_sheets': bed_sheets,
    'reflector': reflector,
    'sketch': sketch,
    'mobile_phone': mobile_phone,
    'duck_shooting': duck_shooting,
    'development': development,
    'nachos': nachos,
    'search_engine': search_engine,
    'bankruptcy': bankruptcy,
    'phone': phone,
    'protection': protection,
    'no_virus': no_virus,
    'smoke': smoke,
    'match': match,
    'announcement': announcement,
    'tractor': tractor,
    'face_scanner': face_scanner,
    'signboard': signboard,
    'reflex_hammer': reflex_hammer,
    'funicular': funicular,
    'hair_transplant': hair_transplant,
    'eat': eat,
    'mortgage': mortgage,
    'pest_control': pest_control,
    'polling_place': polling_place,
    'face_of_a_woman_outline': face_of_a_woman_outline,
    'thunderbolt': thunderbolt,
    'embroidery': embroidery,
    'therapist': therapist,
    'growth': growth,
    'tourism': tourism,
    'military_hat': military_hat,
    'skate_park': skate_park,
    'toothpaste': toothpaste,
    'aquarium': aquarium,
    'fabric': fabric,
    'tree': tree,
    'id_card': id_card,
    'noise': noise,
    'hotels': hotels,
    'key_chain': key_chain,
    'dishes': dishes,
    'express_mail': express_mail,
    'cosmetics': cosmetics,
    'calendar': calendar,
    'license_plate': license_plate,
    'sausage': sausage,
    'renovation': renovation,
    'lotion': lotion,
    'carbon_dioxide': carbon_dioxide,
    'customs': customs,
    'geriatrics': geriatrics,
    'pets': pets,
    'couple_with_daughter_in_a_heart': couple_with_daughter_in_a_heart,
    'zoo': zoo,
    'examination': examination,
    'communication': communication,
    'electronic_cigarette': electronic_cigarette,
    'pension': pension,
    'glue': glue,
    'nutritionist': nutritionist,
    'pharmacies': pharmacies,
    'literature': literature,
    'dermatology': dermatology,
    'cheese': cheese,
    'chair': chair,
    'ATV': ATV,
    'console': console,
    'compact_disk': compact_disk,
    'employee': employee,
    'transport': transport,
    'suitcases': suitcases,
    'canal': canal,
    'wig': wig,
    'airbrush': airbrush,
    'ear': ear,
    'flame': flame,
    'grocery': grocery,
    'atom': atom,
    'other': other,
    'ice_cream': ice_cream,
    'sport_goods': sport_goods,
    'bowling_pin': bowling_pin,
    'parking': parking,
    'psychology': psychology,
    'lawyer': lawyer,
    'shops': shops,
    'hostels': hostels,
    'souvenirs': souvenirs,
    'shopping_cart': shopping_cart,
    'airplane': airplane,
    'spa': spa,
    'automotive': automotive,
    'female': female,
    'ski': ski,
    'baby_dummy': baby_dummy,
    'plumbing': plumbing,
    'mirror': mirror,
    'building': building,
    'headlight': headlight,
    'celebration': celebration,
    'history': history,
    'gavel': gavel,
    'rack': rack,
    'tow_truck': tow_truck,
    'med_center': med_center,
    'garbage': garbage,
    'tuning': tuning,
    'roof': roof,
    'diving_goggles': diving_goggles,
    'swimming_pool': swimming_pool,
    'comic': comic,
    'water_cooler': water_cooler,
    'karaoke': karaoke,
    'cleaning': cleaning,
  };

}