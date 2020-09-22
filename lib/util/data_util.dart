import 'package:intl/intl.dart';

class DataUtil {

  static String getDataFormatada(DateTime data){
    if (data == null){
      return null;
    }
    return  DateFormat('dd/MM/yyyy').format(data);
  }

  static String getDataHoraFormatada(DateTime data){
    if (data == null){
      return null;
    }
    return  DateFormat('dd/MM/yyyy HH:MM:SS').format(data);
  }

  static String getDataFormatadaStr(String data){
    if (data == null){
      return null;
    }
    return  DateFormat('dd/MM/yyyy').format(DateTime.parse(data));
  }

  static DateTime getDateTimeFromString(String dataStr){
    if (dataStr == null){
      return null;
    }

    return DateFormat('dd/MM/yyyy HH:MM:SS').parse(dataStr);
  }
}