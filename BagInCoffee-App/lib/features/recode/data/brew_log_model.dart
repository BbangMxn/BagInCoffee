// Re-export from API layer
export '../../../api/recodes.dart'
    show Recode, ExtractionStep, CreateRecodeDto, UpdateRecodeDto;

import '../../../api/recodes.dart';

// Type alias for backward compatibility
typedef BrewLog = Recode;
