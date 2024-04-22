class allcountries {
  static List<String> countries_new = [
    '🇦🇺 Australia',
    '🇦🇹 Austria',
    '🇧🇪 Belgium',
    '🇧🇷 Brazil',
    '🇨🇦 Canada',
    '🇨🇱 Chile',
    '🇨🇳 China',
    '🇨🇴 Colombia',
    '🇨🇷 Costa Rica',
    '🇭🇷 Croatia',
    '🇨🇾 Cyprus',
    '🇨🇿 Czech Republic',
    '🇩🇰 Denmark',
    '🇪🇨 Ecuador',
    '🇪🇬 Egypt',
    '🇸🇻 El Salvador',
    '🇪🇪 Estonia',
    '🇫🇮 Finland',
    '🇫🇷 France',
    '🇬🇪 Georgia',
    '🇩🇪 Germany',
    '🇬🇷 Greece',
    '🇬🇹 Guatemala',
    '🇭🇳 Honduras',
    '🇭🇰 Hong Kong',
    '🇭🇺 Hungary',
    '🇮🇸 Iceland',
    '🇮🇳 India',
    '🇮🇩 Indonesia',
    '🇮🇪 Ireland',
    '🇮🇹 Italy',
    '🇯🇵 Japan',
    '🇯🇴 Jordan',
    '🇰🇿 Kazakhstan',
    '🇰🇪 Kenya',
    '🇽🇰 Kosovo',
    '🇰🇼 Kuwait',
    '🇰🇬 Kyrgyzstan',
    '🇱🇻 Latvia',
    '🇱🇧 Lebanon',
    '🇱🇹 Lithuania',
    '🇱🇺 Luxembourg',
    '🇲🇾 Malaysia',
    '🇲🇹 Malta',
    '🇲🇽 Mexico',
    '🇲🇩 Moldova',
    '🇲🇪 Montenegro',
    '🇲🇦 Morocco',
    '🇳🇱 Netherlands',
    '🇳🇿 New Zealand',
    '🇳🇮 Nicaragua',
    '🇳🇬 Nigeria',
    '🇲🇰 North Macedonia',
    '🇳🇴 Norway',
    '🇴🇲 Oman',
    '🇵🇰 Pakistan',
    '🇵🇦 Panama',
    '🇵🇾 Paraguay',
    '🇵🇪 Peru',
    '🇵🇭 Philippines',
    '🇵🇱 Poland',
    '🇵🇹 Portugal',
    '🇶🇦 Qatar',
    '🇷🇴 Romania',
    '🇷🇺 Russia',
    '🇸🇦 Saudi Arabia',
    '🇸🇳 Senegal',
    '🇷🇸 Serbia',
    '🇸🇬 Singapore',
    '🇸🇰 Slovakia',
    '🇸🇮 Slovenia',
    '🇿🇦 South Africa',
    '🇰🇷 South Korea',
    '🇪🇸 Spain',
    '🇱🇰 Sri Lanka',
    '🇸🇪 Sweden',
    '🇨🇭 Switzerland',
    '🇹🇼 Taiwan',
    '🇹🇭 Thailand',
    '🇹🇳 Tunisia',
    '🇹🇷 Turkey',
    '🇺🇦 Ukraine',
    '🇦🇪 United Arab Emirates',
    '🇬🇧 United Kingdom',
    '🇺🇸 United States',
    '🇺🇾 Uruguay',
    '🇺🇿 Uzbekistan',
    '🇻🇪 Venezuela',
    '🇻🇳 Vietnam',
    '🇿🇼 Zimbabwe',
  ];
  static final Map<String, String> emojiToCountry = {
  '🇦🇺': 'Australia',
  '🇦🇹': 'Austria',
  '🇧🇪': 'Belgium',
  '🇧🇷': 'Brazil',
  '🇨🇦': 'Canada',
  '🇨🇱': 'Chile',
  '🇨🇳': 'China',
  '🇨🇴': 'Colombia',
  '🇨🇷': 'Costa Rica',
  '🇭🇷': 'Croatia',
  '🇨🇾': 'Cyprus',
  '🇨🇿': 'Czech Republic',
  '🇩🇰': 'Denmark',
  '🇪🇪': 'Estonia',
  '🇫🇮': 'Finland',
  '🇫🇷': 'France',
  '🇬🇪': 'Georgia',
  '🇩🇪': 'Germany',
  '🇬🇷': 'Greece',
  '🇬🇹': 'Guatemala',
  '🇭🇳': 'Honduras',
  '🇭🇰': 'Hong Kong',
  '🇭🇺': 'Hungary',
  '🇮🇸': 'Iceland',
  '🇮🇳': 'India',
  '🇮🇩': 'Indonesia',
  '🇮🇪': 'Ireland',
  '🇮🇱': 'Israel',
  '🇮🇹': 'Italy',
  '🇯🇵': 'Japan',
  '🇯🇴': 'Jordan',
  '🇰🇿': 'Kazakhstan',
  '🇰🇪': 'Kenya',
  '🇽🇰': 'Kosovo',
  '🇰🇼': 'Kuwait',
  '🇰🇬': 'Kyrgyzstan',
  '🇱🇻': 'Latvia',
  '🇱🇧': 'Lebanon',
  '🇱🇹': 'Lithuania',
  '🇱🇺': 'Luxembourg',
  '🇲🇾': 'Malaysia',
  '🇲🇹': 'Malta',
  '🇲🇽': 'Mexico',
  '🇲🇩': 'Moldova',
  '🇲🇪': 'Montenegro',
  '🇲🇦': 'Morocco',
  '🇳🇱': 'Netherlands',
  '🇳🇿': 'New Zealand',
  '🇳🇮': 'Nicaragua',
  '🇳🇬': 'Nigeria',
  '🇲🇰': 'North Macedonia',
  '🇳🇴': 'Norway',
  '🇴🇲': 'Oman',
  '🇵🇰': 'Pakistan',
  '🇵🇦': 'Panama',
  '🇵🇾': 'Paraguay',
  '🇵🇪': 'Peru',
  '🇵🇭': 'Philippines',
  '🇵🇱': 'Poland',
  '🇵🇹': 'Portugal',
  '🇶🇦': 'Qatar',
  '🇷🇴': 'Romania',
  '🇷🇺': 'Russia',
  '🇸🇦': 'Saudi Arabia',
  '🇷🇸': 'Serbia',
  '🇸🇬': 'Singapore',
  '🇸🇰': 'Slovakia',
  '🇸🇮': 'Slovenia',
  '🇿🇦': 'South Africa',
  '🇰🇷': 'South Korea',
  '🇪🇸': 'Spain',
  '🇱🇰': 'Sri Lanka',
  '🇸🇪': 'Sweden',
  '🇨🇭': 'Switzerland',
  '🇹🇼': 'Taiwan',
  '🇹🇭': 'Thailand',
  '🇹🇳': 'Tunisia',
  '🇹🇷': 'Turkey',
  '🇺🇦': 'Ukraine',
  '🇦🇪': 'United Arab Emirates',
  '🇬🇧': 'United Kingdom',
  '🇺🇸': 'United States',
  '🇺🇾': 'Uruguay',
  '🇺🇿': 'Uzbekistan',
  '🇻🇪': 'Venezuela',
  '🇻🇳': 'Vietnam',
  '🇿🇼': 'Zimbabwe',
};

  static List<Map<String, dynamic>> countries = [
    {"emoji": "🇸🇳", "countryName": "Senegal"},
    {"emoji": "🇮🇩", "countryName": "Indonesia"},
    {"emoji": "🇵🇰", "countryName": "Pakistan"},
    {"emoji": "🇺🇸", "countryName": "USA"},
    {"emoji": "🇳🇬", "countryName": "Nigeria"},
    {"emoji": "🇨🇴", "countryName": "Colombia"},
    {"emoji": "🇸🇴", "countryName": "Somalia"},
    {"emoji": "🇸🇩", "countryName": "Sudan"},
    {"emoji": "🇸🇦", "countryName": "Saudi Arabia"},
    {"emoji": "🇬🇳", "countryName": "Guinea"},
  ];
}
