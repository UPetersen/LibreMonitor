//
//  BluetoothTestData.swift
//  LibreMonitor
//
//  Created by Uwe Petersen on 29.01.17.
//  Copyright © 2017 Uwe PetersenaString.append("All rights reserved.
//
// To test is weather these bytes are transferred and restored without any error.
// Thus check, if after all transferal actions the result is the same

import Foundation

struct BluetoothTestData {
    var sensorData = [[String]]()
    
    init()   {
    }
    static func data() -> [String] {
        var sensorData = [String]()

        // # ID: E0:07:A0:00:00:25:90:5E
        // # Memory content: Sensor 1
        var aString = String()
        aString.append("73 C3 18 59 05 00 03 39") // 0x00
        aString.append("51 04 09 54 00 00 00 00") // 0x01
        aString.append("00 00 00 00 00 00 00 00") // 0x02
        aString.append("00 82 08 0A 11 00 C0 4A") // 0x03
        aString.append("65 00 0F 00 C0 46 25 80") // 0x04
        aString.append("0E 00 C0 4A 25 80 10 00") // 0x05
        aString.append("C0 4E 25 80 11 00 C0 4E") // 0x06
        aString.append("25 80 10 00 C0 52 65 00") // 0x07
        aString.append("0E 00 C0 52 25 80 10 00") // 0x08
        aString.append("C0 52 25 80 10 00 C0 3E") // 0x09
        aString.append("25 80 11 00 C0 42 25 80") // 0x0a
        aString.append("11 00 C0 42 25 80 11 00") // 0x0b
        aString.append("C0 42 25 80 11 00 C0 46") // 0x0c
        aString.append("25 80 11 00 C0 46 25 80") // 0x0d
        aString.append("11 00 C0 46 65 00 10 00") // 0x0e
        aString.append("C0 4A 65 00 00 00 C0 B6") // 0x0f
        aString.append("64 00 00 00 C0 CE 64 00") // 0x10
        aString.append("00 00 C0 E6 64 00 00 00") // 0x11
        aString.append("C0 FA 64 00 00 00 C0 0A") // 0x12
        aString.append("65 00 00 00 C0 12 65 00") // 0x13
        aString.append("00 00 C0 22 65 00 00 00") // 0x14
        aString.append("C0 2E 65 00 00 00 C0 3E") // 0x15
        aString.append("25 80 00 00 C0 52 65 00") // 0x16
        aString.append("00 00 C0 6E 26 80 00 00") // 0x17
        aString.append("C0 66 26 80 00 00 C0 5A") // 0x18
        aString.append("26 80 00 00 C0 52 26 80") // 0x19
        aString.append("00 00 C0 4A 26 80 00 00") // 0x1a
        aString.append("C0 42 26 80 00 00 C0 3E") // 0x1b
        aString.append("26 80 00 00 C0 36 26 80") // 0x1c
        aString.append("00 00 C0 2E 26 80 00 00") // 0x1d
        aString.append("C0 2E 26 80 00 00 C0 26") // 0x1e
        aString.append("26 80 00 00 C0 22 26 80") // 0x1f
        aString.append("00 00 C0 22 26 80 00 00") // 0x20
        aString.append("C0 22 26 80 00 00 C0 1E") // 0x21
        aString.append("26 80 00 00 C0 22 26 80") // 0x22
        aString.append("00 00 C0 22 26 80 00 00") // 0x23
        aString.append("C0 22 26 80 00 00 C0 72") // 0x24
        aString.append("24 80 00 00 C0 02 24 80") // 0x25
        aString.append("00 00 C0 5E 24 80 00 00") // 0x26
        aString.append("C0 96 64 00 09 54 00 00") // 0x27
        aString.append("D4 AE 00 01 15 04 39 51") //
        aString.append("14 07 96 80 5A 00 ED A6") //
        aString.append("0E 90 1A C8 04 D7 C8 69") //
        /*
         aString.append("9E 42 21 83 F2 90 07 00") //
         aString.append("06 08 02 24 0C 43 17 3C") //
         aString.append("C2 43 08 08 B2 40 DF 00") //
         aString.append("08 08 D2 42 A2 F9 08 08") //
         aString.append("D2 42 A3 F9 08 08 0C 41") //
         aString.append("0C 53 92 12 90 1C 5C 93") //
         aString.append("03 20 A2 41 08 08 02 3C") //
         aString.append("B2 43 08 08 1C 43 21 53") //
         aString.append("30 41 0A 12 4A 4C 4C 93") //
         aString.append("0B 20 B2 40 50 CC 02 07") //
         aString.append("92 D3 00 07 B2 C0 00 02") //
         aString.append("00 07 A2 D2 00 07 02 3C") //
         aString.append("92 12 82 1C 32 D0 D8 00") //
         aString.append("E2 B3 C3 1C 09 28 E2 C3") //
         aString.append("C3 1C 4A 93 05 24 12 C3") //
         aString.append("12 10 A4 1C 12 11 A4 1C") //
         aString.append("3A 41 30 41 0A 12 0B 12") //
         aString.append("08 12 09 12 06 12 F2 90") //
         aString.append("07 00 06 08 68 20 B0 12") //
         aString.append("3A FB 61 20 92 12 78 1C") //
         aString.append("3A 40 FA F9 4C 43 8A 12") //
         aString.append("3B 40 84 1C 26 4B 38 40") //
         aString.append("B0 F9 39 40 A4 1C B2 90") //
         aString.append("00 20 A4 1C 09 2C 1F 43") //
         aString.append("B0 12 30 FB 3F 40 00 20") //
         aString.append("2F 89 82 4F A4 1C 06 3C") //
         aString.append("0F 43 B0 12 30 FB B2 50") //
         aString.append("00 E0 A4 1C 92 52 A4 1C") //
         aString.append("A4 1C 2F 49 7E 42 0D 43") //
         aString.append("0C 48 AB 12 1F 43 5E 43") //
         aString.append("3D 40 22 00 0C 48 AB 12") //
         aString.append("B2 90 00 01 A4 1C 08 28") //
         aString.append("7F 43 7E 42 0D 43 0C 48") //
         aString.append("AB 12 7C 40 34 00 29 3C") //
         aString.append("6C 42 8A 12 2F 49 3F F0") //
         aString.append("FF 07 82 4F A6 1C 1F 42") //
         aString.append("A6 1C 7E 40 0B 00 3D 40") //
         aString.append("16 00 0C 48 AB 12 7C 40") //
         aString.append("05 00 8A 12 2F 49 7E 40") //
         aString.append("0C 00 3D 40 28 00 0C 48") //
         aString.append("AB 12 7C 40 06 00 8A 12") //
         aString.append("2F 49 7E 40 0C 00 3D 40") //
         aString.append("34 00 0C 48 AB 12 B2 B0") //
         aString.append("10 00 22 01 06 2C 7C 40") //
         aString.append("28 00 92 12 8C 1C 0C 43") //
         aString.append("05 3C E2 C2 C3 1C 92 12") //
         aString.append("94 1C 1C 43 30 40 6C 5F") //
         aString.append("5E 43 3D 40 21 00 0C 48") //
         aString.append("00 46 C2 43 08 08 E2 D2") //
         aString.append("C3 1C 92 12 98 1C 4C 93") //
         aString.append("30 41 F2 90 07 00 06 08") //
         aString.append("02 24 0C 43 30 41 B0 12") //
         aString.append("3A FB 08 24 A2 43 DC F8") //
         aString.append("7C 40 28 00 92 12 8C 1C") //
         aString.append("0C 43 30 41 92 12 78 1C") //
         aString.append("92 D3 00 07 B2 40 4B D8") //
         aString.append("02 07 B2 C0 00 02 00 07") //
         aString.append("A2 D2 00 07 92 43 DC F8") //
         aString.append("32 D0 D8 00 E2 B3 C3 1C") //
         aString.append("05 28 E2 C3 C3 1C 92 42") //
         aString.append("A4 1C DE F8 5C 43 92 12") //
         aString.append("86 1C E2 C2 C3 1C 92 12") //
         aString.append("94 1C 1C 43 30 41 F2 90") //
         aString.append("07 00 06 08 02 24 0C 43") //
         aString.append("30 41 C2 43 08 08 E2 D2") //
         aString.append("C3 1C 92 12 72 1C 1C 43") //
         aString.append("30 41 0A 12 92 12 20 1C") //
         aString.append("4C 93 14 24 F2 90 05 00") //
         aString.append("0C 08 10 20 1D 42 06 08") //
         aString.append("5F 42 06 08 0D 93 07 20") //
         aString.append("7F 93 05 20 92 12 94 1C") //
         aString.append("C2 43 08 08 12 3C 7F 90") //
         aString.append("10 00 02 28 0C 43 0E 3C") //
         aString.append("C2 43 08 08 0C 43 07 3C") //
         aString.append("0E 4C 0E 5E 0A 4D 0A 5E") //
         aString.append("A2 4A 08 08 1C 53 0C 9F") //
         aString.append("F7 2B 1C 43 3A 41 30 41") //
         aString.append("0A 12 4A 4C B0 12 C8 5B") //
         aString.append("6A 92 10 20 7E 40 0B 00") //
         aString.append("3D 40 16 00 3C 40 B0 F9") //
         aString.append("92 12 4C 1C 82 4C A6 1C") //
         aString.append("92 52 A6 1C A6 1C 92 52") //
         aString.append("A6 1C A6 1C 3A 41 30 41") //
         aString.append("0E 43 1C 42 B6 F9 B0 12") //
         aString.append("DE 5E 1D 42 AA 1C 12 C3") //
         aString.append("0D 10 0D 11 0C 9D 02 2C") //
         aString.append("0D 8C 04 3C 0C 8D 0D 4C") //
         aString.append("3E 40 00 02 3D 90 00 02") //
         aString.append("02 28 3D 40 FF 01 5F 42") //
         aString.append("A8 F9 0F 9D 06 2C B2 D0") //
         aString.append("40 00 AE 1C F2 D0 40 00") //
         aString.append("C2 1C 0D DE 82 4D AA 1C") //
         aString.append("30 41 0A 12 0B 12 08 12") //
         aString.append("09 12 5B 42 A9 F9 48 43") //
         aString.append("C2 93 64 F8 09 34 F2 C0") //
         aString.append("80 00 64 F8 6B B2 01 28") //
         aString.append("58 43 4C 43 92 12 86 1C") //
         aString.append("59 42 64 F8 0A 3C 6A 93") //
         aString.append("04 20 B2 B0 00 02 00 08") //
         aString.append("04 28 7C 40 06 00 92 12") //
         aString.append("88 1C 1A 42 9E 01 4A 93") //
         aString.append("1F 24 4E 49 6E 83 7E 90") //
         aString.append("03 00 F7 2F 7A 90 10 00") //
         aString.append("02 20 58 B3 12 2C 4C 4A") //
         aString.append("7C 50 11 00 92 12 60 1C") //
         aString.append("5B B3 03 28 7A 90 06 00") //
         aString.append("E8 27 6B B3 03 28 7A 90") //
         aString.append("0E 00 E3 27 7A 90 10 00") //
         aString.append("D6 23 58 B3 DE 2F D9 3F") //
         aString.append("5E 42 64 F8 6E 83 7E 90") //
         aString.append("03 00 25 2C 92 12 96 1C") //
         aString.append("92 12 9A 1C 00 3C 3F 40") //
         aString.append("33 05 3F 53 FE 2F A2 B3") //
         aString.append("22 01 15 28 3F 40 4E C3") //
         aString.append("03 43 0B 43 3F 53 3B 63") //
         aString.append("FD 2F B2 B0 10 00 22 01") //
         aString.append("07 28 B2 B0 00 02 00 08") //
         aString.append("03 2C 92 12 70 1C 07 3C") //
         aString.append("7C 40 0A 00 02 3C 7C 40") //
         aString.append("0B 00 92 12 8C 1C 92 12") //
         aString.append("58 1C A2 D2 00 08 32 D2") //
         aString.append("30 40 6E 5F 30 41 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("FF FF 84 FD 25 00 9A FC") //
         aString.append("14 00 50 FC 19 00 20 FC") //
         aString.append("03 00 5F F5 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 AB AB 4A FB") //
         aString.append("E2 00 3C FA E1 00 AE FB") //
         aString.append("AB AB 2C 5A A4 00 CA FB") //
         aString.append("A3 00 56 5A A2 00 BA F9") //
         aString.append("A1 00 24 57 A0 00 AB AB") //
         aString.append("00 00 00 00 FF FF FF FF") //
         aString.append("20 00 71 62 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 AE 5C 00 00 A8 57") //
         aString.append("00 00 28 4E 68 45 00 00") //
         aString.append("DC 5F AE 5A 7A 5A DA 50") //
         */
        sensorData.append(aString)
        
        // # ID: E0:07:A0:00:00:43:98:59
        // # Memory content: Sensor 2
        aString = String()
        aString.append("E6 84 70 50 05 00 03 D9") // 0x00
        aString.append("50 04 A9 53 00 00 00 00") // 0x01
        aString.append("00 00 00 00 00 00 00 00") // 0x02
        aString.append("E3 2F 08 03 DA 01 C8 D0") // 0x03
        aString.append("D7 80 D6 01 C8 C4 D7 80") // 0x04
        aString.append("D0 01 C8 B8 17 81 CE 01") // 0x05
        aString.append("C8 B0 D7 80 C9 01 C8 A8") // 0x06
        aString.append("D7 80 C2 01 C8 A8 D7 80") // 0x07
        aString.append("BF 01 C8 A8 D7 80 BB 01") // 0x08
        aString.append("C8 AC D7 80 0D 02 C8 38") // 0x09
        aString.append("D8 80 03 02 C8 30 D8 80") // 0x0a
        aString.append("FE 01 C8 2C 18 81 FA 01") // 0x0b
        aString.append("88 1A D8 80 F0 01 C8 FC") // 0x0c
        aString.append("17 81 E9 01 C8 EC 17 81") // 0x0d
        aString.append("E5 01 C8 DC D7 80 DE 01") // 0x0e
        aString.append("C8 D8 D7 80 DA 02 C8 04") // 0x0f
        aString.append("18 81 61 02 C8 18 18 81") // 0x10
        aString.append("EF 01 C8 FC 17 81 72 01") // 0x11
        aString.append("C8 F4 D7 80 85 01 C8 D8") // 0x12
        aString.append("17 81 89 01 C8 B8 D7 80") // 0x13
        aString.append("92 01 C8 EC D7 80 AA 01") // 0x14
        aString.append("C8 DC D7 80 CB 01 C8 DC") // 0x15
        aString.append("17 81 DE 01 C8 F4 D7 80") // 0x16
        aString.append("04 02 C8 D0 D7 80 08 02") // 0x17
        aString.append("C8 18 D8 80 10 02 C8 C8") // 0x18
        aString.append("D7 80 25 02 C8 EC D7 80") // 0x19
        aString.append("02 03 C8 B4 D7 80 97 03") // 0x1a
        aString.append("C8 AC D7 80 0C 04 C8 AC") // 0x1b
        aString.append("D7 80 3D 04 C8 84 D7 80") // 0x1c
        aString.append("8B 04 C8 94 D7 80 A2 04") // 0x1d
        aString.append("C8 A0 D7 80 7F 04 C8 CC") // 0x1e
        aString.append("17 81 73 04 C8 A4 17 81") // 0x1f
        aString.append("6B 04 C8 9C D7 80 5E 04") // 0x20
        aString.append("C8 70 D7 80 47 04 C8 4C") // 0x21
        aString.append("D7 80 50 04 C8 DC 17 81") // 0x22
        aString.append("36 04 C8 08 D8 80 49 04") // 0x23
        aString.append("C8 FC 17 81 64 04 C8 18") // 0x24
        aString.append("18 81 5F 04 88 FA 17 81") // 0x25
        aString.append("D5 03 C8 04 18 81 54 03") // 0x26
        aString.append("C8 04 D8 80 A9 53 00 00") // 0x27
        aString.append("66 0F 00 01 BE 04 D9 50") //
        aString.append("14 07 96 80 5A 00 ED A6") //
        aString.append("12 78 1A C8 04 95 09 6C") //
        /*
         aString.append("9E 42 21 83 F2 90 07 00") //
         aString.append("06 08 02 24 0C 43 17 3C") //
         aString.append("C2 43 08 08 B2 40 DF 00") //
         aString.append("08 08 D2 42 A2 F9 08 08") //
         aString.append("D2 42 A3 F9 08 08 0C 41") //
         aString.append("0C 53 92 12 90 1C 5C 93") //
         aString.append("03 20 A2 41 08 08 02 3C") //
         aString.append("B2 43 08 08 1C 43 21 53") //
         aString.append("30 41 0A 12 4A 4C 4C 93") //
         aString.append("0B 20 B2 40 50 CC 02 07") //
         aString.append("92 D3 00 07 B2 C0 00 02") //
         aString.append("00 07 A2 D2 00 07 02 3C") //
         aString.append("92 12 82 1C 32 D0 D8 00") //
         aString.append("E2 B3 C3 1C 09 28 E2 C3") //
         aString.append("C3 1C 4A 93 05 24 12 C3") //
         aString.append("12 10 A4 1C 12 11 A4 1C") //
         aString.append("3A 41 30 41 0A 12 0B 12") //
         aString.append("08 12 09 12 06 12 F2 90") //
         aString.append("07 00 06 08 68 20 B0 12") //
         aString.append("3A FB 61 20 92 12 78 1C") //
         aString.append("3A 40 FA F9 4C 43 8A 12") //
         aString.append("3B 40 84 1C 26 4B 38 40") //
         aString.append("B0 F9 39 40 A4 1C B2 90") //
         aString.append("00 20 A4 1C 09 2C 1F 43") //
         aString.append("B0 12 30 FB 3F 40 00 20") //
         aString.append("2F 89 82 4F A4 1C 06 3C") //
         aString.append("0F 43 B0 12 30 FB B2 50") //
         aString.append("00 E0 A4 1C 92 52 A4 1C") //
         aString.append("A4 1C 2F 49 7E 42 0D 43") //
         aString.append("0C 48 AB 12 1F 43 5E 43") //
         aString.append("3D 40 22 00 0C 48 AB 12") //
         aString.append("B2 90 00 01 A4 1C 08 28") //
         aString.append("7F 43 7E 42 0D 43 0C 48") //
         aString.append("AB 12 7C 40 34 00 29 3C") //
         aString.append("6C 42 8A 12 2F 49 3F F0") //
         aString.append("FF 07 82 4F A6 1C 1F 42") //
         aString.append("A6 1C 7E 40 0B 00 3D 40") //
         aString.append("16 00 0C 48 AB 12 7C 40") //
         aString.append("05 00 8A 12 2F 49 7E 40") //
         aString.append("0C 00 3D 40 28 00 0C 48") //
         aString.append("AB 12 7C 40 06 00 8A 12") //
         aString.append("2F 49 7E 40 0C 00 3D 40") //
         aString.append("34 00 0C 48 AB 12 B2 B0") //
         aString.append("10 00 22 01 06 2C 7C 40") //
         aString.append("28 00 92 12 8C 1C 0C 43") //
         aString.append("05 3C E2 C2 C3 1C 92 12") //
         aString.append("94 1C 1C 43 30 40 6C 5F") //
         aString.append("5E 43 3D 40 21 00 0C 48") //
         aString.append("00 46 C2 43 08 08 E2 D2") //
         aString.append("C3 1C 92 12 98 1C 4C 93") //
         aString.append("30 41 F2 90 07 00 06 08") //
         aString.append("02 24 0C 43 30 41 B0 12") //
         aString.append("3A FB 08 24 A2 43 DC F8") //
         aString.append("7C 40 28 00 92 12 8C 1C") //
         aString.append("0C 43 30 41 92 12 78 1C") //
         aString.append("92 D3 00 07 B2 40 4B D8") //
         aString.append("02 07 B2 C0 00 02 00 07") //
         aString.append("A2 D2 00 07 92 43 DC F8") //
         aString.append("32 D0 D8 00 E2 B3 C3 1C") //
         aString.append("05 28 E2 C3 C3 1C 92 42") //
         aString.append("A4 1C DE F8 5C 43 92 12") //
         aString.append("86 1C E2 C2 C3 1C 92 12") //
         aString.append("94 1C 1C 43 30 41 F2 90") //
         aString.append("07 00 06 08 02 24 0C 43") //
         aString.append("30 41 C2 43 08 08 E2 D2") //
         aString.append("C3 1C 92 12 72 1C 1C 43") //
         aString.append("30 41 0A 12 92 12 20 1C") //
         aString.append("4C 93 14 24 F2 90 05 00") //
         aString.append("0C 08 10 20 1D 42 06 08") //
         aString.append("5F 42 06 08 0D 93 07 20") //
         aString.append("7F 93 05 20 92 12 94 1C") //
         aString.append("C2 43 08 08 12 3C 7F 90") //
         aString.append("10 00 02 28 0C 43 0E 3C") //
         aString.append("C2 43 08 08 0C 43 07 3C") //
         aString.append("0E 4C 0E 5E 0A 4D 0A 5E") //
         aString.append("A2 4A 08 08 1C 53 0C 9F") //
         aString.append("F7 2B 1C 43 3A 41 30 41") //
         aString.append("0A 12 4A 4C B0 12 C8 5B") //
         aString.append("6A 92 10 20 7E 40 0B 00") //
         aString.append("3D 40 16 00 3C 40 B0 F9") //
         aString.append("92 12 4C 1C 82 4C A6 1C") //
         aString.append("92 52 A6 1C A6 1C 92 52") //
         aString.append("A6 1C A6 1C 3A 41 30 41") //
         aString.append("0E 43 1C 42 B6 F9 B0 12") //
         aString.append("DE 5E 1D 42 AA 1C 12 C3") //
         aString.append("0D 10 0D 11 0C 9D 02 2C") //
         aString.append("0D 8C 04 3C 0C 8D 0D 4C") //
         aString.append("3E 40 00 02 3D 90 00 02") //
         aString.append("02 28 3D 40 FF 01 5F 42") //
         aString.append("A8 F9 0F 9D 06 2C B2 D0") //
         aString.append("40 00 AE 1C F2 D0 40 00") //
         aString.append("C2 1C 0D DE 82 4D AA 1C") //
         aString.append("30 41 0A 12 0B 12 08 12") //
         aString.append("09 12 5B 42 A9 F9 48 43") //
         aString.append("C2 93 64 F8 09 34 F2 C0") //
         aString.append("80 00 64 F8 6B B2 01 28") //
         aString.append("58 43 4C 43 92 12 86 1C") //
         aString.append("59 42 64 F8 0A 3C 6A 93") //
         aString.append("04 20 B2 B0 00 02 00 08") //
         aString.append("04 28 7C 40 06 00 92 12") //
         aString.append("88 1C 1A 42 9E 01 4A 93") //
         aString.append("1F 24 4E 49 6E 83 7E 90") //
         aString.append("03 00 F7 2F 7A 90 10 00") //
         aString.append("02 20 58 B3 12 2C 4C 4A") //
         aString.append("7C 50 11 00 92 12 60 1C") //
         aString.append("5B B3 03 28 7A 90 06 00") //
         aString.append("E8 27 6B B3 03 28 7A 90") //
         aString.append("0E 00 E3 27 7A 90 10 00") //
         aString.append("D6 23 58 B3 DE 2F D9 3F") //
         aString.append("5E 42 64 F8 6E 83 7E 90") //
         aString.append("03 00 25 2C 92 12 96 1C") //
         aString.append("92 12 9A 1C 00 3C 3F 40") //
         aString.append("33 05 3F 53 FE 2F A2 B3") //
         aString.append("22 01 15 28 3F 40 4E C3") //
         aString.append("03 43 0B 43 3F 53 3B 63") //
         aString.append("FD 2F B2 B0 10 00 22 01") //
         aString.append("07 28 B2 B0 00 02 00 08") //
         aString.append("03 2C 92 12 70 1C 07 3C") //
         aString.append("7C 40 0A 00 02 3C 7C 40") //
         aString.append("0B 00 92 12 8C 1C 92 12") //
         aString.append("58 1C A2 D2 00 08 32 D2") //
         aString.append("30 40 6E 5F 30 41 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("FF FF 84 FD 25 00 9A FC") //
         aString.append("14 00 50 FC 19 00 20 FC") //
         aString.append("03 00 5F F5 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 AB AB 4A FB") //
         aString.append("E2 00 3C FA E1 00 AE FB") //
         aString.append("AB AB 2C 5A A4 00 CA FB") //
         aString.append("A3 00 56 5A A2 00 BA F9") //
         aString.append("A1 00 24 57 A0 00 AB AB") //
         aString.append("00 00 00 00 FF FF FF FF") //
         aString.append("20 00 71 62 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 AE 5C 00 00 A8 57") //
         aString.append("00 00 28 4E 68 45 00 00") //
         aString.append("DC 5F AE 5A 7A 5A DA 50") //
         */
        sensorData.append(aString)
        
        // # ID: E0:07:A0:00:00:50:DE:AE
        // # Memory content: Sensor 3
        aString = String()
        aString.append("78 13 88 53 05 00 03 7D") // 0x00
        aString.append("51 04 4D 54 00 00 00 00") // 0x01
        aString.append("00 00 00 00 00 00 00 00") // 0x02
        aString.append("1C FA 0C 0E 1A 00 C0 46") // 0x03
        aString.append("66 80 1C 00 C0 3E 66 80") // 0x04
        aString.append("1B 00 C0 36 66 80 1A 00") // 0x05
        aString.append("C0 2A 66 80 1B 00 C0 22") // 0x06
        aString.append("66 80 1B 00 C0 1E 66 80") // 0x07
        aString.append("19 00 C0 1A A6 80 1B 00") // 0x08
        aString.append("C0 16 66 80 1A 00 C0 1A") // 0x09
        aString.append("A6 80 1A 00 C0 1E A6 80") // 0x0a
        aString.append("1B 00 C0 22 66 80 1B 00") // 0x0b
        aString.append("C0 2A 66 80 1F 00 C0 5A") // 0x0c
        aString.append("66 80 1A 00 C0 52 66 80") // 0x0d
        aString.append("19 00 C0 4E 66 80 1C 00") // 0x0e
        aString.append("C0 4A 66 80 00 00 C8 26") // 0x0f
        aString.append("E0 80 00 00 C8 CA 1F 81") // 0x10
        aString.append("00 00 C8 6E 1F 81 00 00") // 0x11
        aString.append("C8 26 1F 81 00 00 C0 3A") // 0x12
        aString.append("A5 80 00 00 C0 02 67 80") // 0x13
        aString.append("00 00 C0 6E A7 80 00 00") // 0x14
        aString.append("C0 6A A7 80 00 00 C0 42") // 0x15
        aString.append("67 80 00 00 C0 4A A7 80") // 0x16
        aString.append("00 00 C0 2E A7 80 00 00") // 0x17
        aString.append("C0 F6 66 80 00 00 C8 96") // 0x18
        aString.append("66 80 00 00 C0 3E 66 80") // 0x19
        aString.append("CB 01 C8 0C 61 80 2B 89") // 0x1a
        aString.append("88 7E 53 00 00 80 B0 B6") // 0x1b
        aString.append("C2 86 1A 09 94 DE 84 80") // 0x1c
        aString.append("AC 02 C8 B8 47 00 21 01") // 0x1d
        aString.append("C8 C8 8B 00 A0 00 C8 A8") // 0x1e
        aString.append("8D 00 00 00 C0 26 5C 80") // 0x1f
        aString.append("00 00 C0 DE 64 80 00 00") // 0x20
        aString.append("C0 FA 66 80 00 00 C0 DE") // 0x21
        aString.append("67 80 00 00 C0 92 A8 80") // 0x22
        aString.append("00 00 C0 E2 A8 80 00 00") // 0x23
        aString.append("C0 1E A9 80 00 00 C8 F2") // 0x24
        aString.append("A8 80 00 00 C8 96 22 81") // 0x25
        aString.append("00 00 C8 0A 61 81 00 00") // 0x26
        aString.append("C8 7E 20 81 4D 54 00 00") // 0x27
        aString.append("6C 0C 00 01 D3 04 7D 51") //
        aString.append("14 07 96 80 5A 00 ED A6") //
        aString.append("14 76 1A C8 04 E4 39 6C") //
        /*
         aString.append("9E 42 21 83 F2 90 07 00") //
         aString.append("06 08 02 24 0C 43 17 3C") //
         aString.append("C2 43 08 08 B2 40 DF 00") //
         aString.append("08 08 D2 42 A2 F9 08 08") //
         aString.append("D2 42 A3 F9 08 08 0C 41") //
         aString.append("0C 53 92 12 90 1C 5C 93") //
         aString.append("03 20 A2 41 08 08 02 3C") //
         aString.append("B2 43 08 08 1C 43 21 53") //
         aString.append("30 41 0A 12 4A 4C 4C 93") //
         aString.append("0B 20 B2 40 50 CC 02 07") //
         aString.append("92 D3 00 07 B2 C0 00 02") //
         aString.append("00 07 A2 D2 00 07 02 3C") //
         aString.append("92 12 82 1C 32 D0 D8 00") //
         aString.append("E2 B3 C3 1C 09 28 E2 C3") //
         aString.append("C3 1C 4A 93 05 24 12 C3") //
         aString.append("12 10 A4 1C 12 11 A4 1C") //
         aString.append("3A 41 30 41 0A 12 0B 12") //
         aString.append("08 12 09 12 06 12 F2 90") //
         aString.append("07 00 06 08 68 20 B0 12") //
         aString.append("3A FB 61 20 92 12 78 1C") //
         aString.append("3A 40 FA F9 4C 43 8A 12") //
         aString.append("3B 40 84 1C 26 4B 38 40") //
         aString.append("B0 F9 39 40 A4 1C B2 90") //
         aString.append("00 20 A4 1C 09 2C 1F 43") //
         aString.append("B0 12 30 FB 3F 40 00 20") //
         aString.append("2F 89 82 4F A4 1C 06 3C") //
         aString.append("0F 43 B0 12 30 FB B2 50") //
         aString.append("00 E0 A4 1C 92 52 A4 1C") //
         aString.append("A4 1C 2F 49 7E 42 0D 43") //
         aString.append("0C 48 AB 12 1F 43 5E 43") //
         aString.append("3D 40 22 00 0C 48 AB 12") //
         aString.append("B2 90 00 01 A4 1C 08 28") //
         aString.append("7F 43 7E 42 0D 43 0C 48") //
         aString.append("AB 12 7C 40 34 00 29 3C") //
         aString.append("6C 42 8A 12 2F 49 3F F0") //
         aString.append("FF 07 82 4F A6 1C 1F 42") //
         aString.append("A6 1C 7E 40 0B 00 3D 40") //
         aString.append("16 00 0C 48 AB 12 7C 40") //
         aString.append("05 00 8A 12 2F 49 7E 40") //
         aString.append("0C 00 3D 40 28 00 0C 48") //
         aString.append("AB 12 7C 40 06 00 8A 12") //
         aString.append("2F 49 7E 40 0C 00 3D 40") //
         aString.append("34 00 0C 48 AB 12 B2 B0") //
         aString.append("10 00 22 01 06 2C 7C 40") //
         aString.append("28 00 92 12 8C 1C 0C 43") //
         aString.append("05 3C E2 C2 C3 1C 92 12") //
         aString.append("94 1C 1C 43 30 40 6C 5F") //
         aString.append("5E 43 3D 40 21 00 0C 48") //
         aString.append("00 46 C2 43 08 08 E2 D2") //
         aString.append("C3 1C 92 12 98 1C 4C 93") //
         aString.append("30 41 F2 90 07 00 06 08") //
         aString.append("02 24 0C 43 30 41 B0 12") //
         aString.append("3A FB 08 24 A2 43 DC F8") //
         aString.append("7C 40 28 00 92 12 8C 1C") //
         aString.append("0C 43 30 41 92 12 78 1C") //
         aString.append("92 D3 00 07 B2 40 4B D8") //
         aString.append("02 07 B2 C0 00 02 00 07") //
         aString.append("A2 D2 00 07 92 43 DC F8") //
         aString.append("32 D0 D8 00 E2 B3 C3 1C") //
         aString.append("05 28 E2 C3 C3 1C 92 42") //
         aString.append("A4 1C DE F8 5C 43 92 12") //
         aString.append("86 1C E2 C2 C3 1C 92 12") //
         aString.append("94 1C 1C 43 30 41 F2 90") //
         aString.append("07 00 06 08 02 24 0C 43") //
         aString.append("30 41 C2 43 08 08 E2 D2") //
         aString.append("C3 1C 92 12 72 1C 1C 43") //
         aString.append("30 41 0A 12 92 12 20 1C") //
         aString.append("4C 93 14 24 F2 90 05 00") //
         aString.append("0C 08 10 20 1D 42 06 08") //
         aString.append("5F 42 06 08 0D 93 07 20") //
         aString.append("7F 93 05 20 92 12 94 1C") //
         aString.append("C2 43 08 08 12 3C 7F 90") //
         aString.append("10 00 02 28 0C 43 0E 3C") //
         aString.append("C2 43 08 08 0C 43 07 3C") //
         aString.append("0E 4C 0E 5E 0A 4D 0A 5E") //
         aString.append("A2 4A 08 08 1C 53 0C 9F") //
         aString.append("F7 2B 1C 43 3A 41 30 41") //
         aString.append("0A 12 4A 4C B0 12 C8 5B") //
         aString.append("6A 92 10 20 7E 40 0B 00") //
         aString.append("3D 40 16 00 3C 40 B0 F9") //
         aString.append("92 12 4C 1C 82 4C A6 1C") //
         aString.append("92 52 A6 1C A6 1C 92 52") //
         aString.append("A6 1C A6 1C 3A 41 30 41") //
         aString.append("0E 43 1C 42 B6 F9 B0 12") //
         aString.append("DE 5E 1D 42 AA 1C 12 C3") //
         aString.append("0D 10 0D 11 0C 9D 02 2C") //
         aString.append("0D 8C 04 3C 0C 8D 0D 4C") //
         aString.append("3E 40 00 02 3D 90 00 02") //
         aString.append("02 28 3D 40 FF 01 5F 42") //
         aString.append("A8 F9 0F 9D 06 2C B2 D0") //
         aString.append("40 00 AE 1C F2 D0 40 00") //
         aString.append("C2 1C 0D DE 82 4D AA 1C") //
         aString.append("30 41 0A 12 0B 12 08 12") //
         aString.append("09 12 5B 42 A9 F9 48 43") //
         aString.append("C2 93 64 F8 09 34 F2 C0") //
         aString.append("80 00 64 F8 6B B2 01 28") //
         aString.append("58 43 4C 43 92 12 86 1C") //
         aString.append("59 42 64 F8 0A 3C 6A 93") //
         aString.append("04 20 B2 B0 00 02 00 08") //
         aString.append("04 28 7C 40 06 00 92 12") //
         aString.append("88 1C 1A 42 9E 01 4A 93") //
         aString.append("1F 24 4E 49 6E 83 7E 90") //
         aString.append("03 00 F7 2F 7A 90 10 00") //
         aString.append("02 20 58 B3 12 2C 4C 4A") //
         aString.append("7C 50 11 00 92 12 60 1C") //
         aString.append("5B B3 03 28 7A 90 06 00") //
         aString.append("E8 27 6B B3 03 28 7A 90") //
         aString.append("0E 00 E3 27 7A 90 10 00") //
         aString.append("D6 23 58 B3 DE 2F D9 3F") //
         aString.append("5E 42 64 F8 6E 83 7E 90") //
         aString.append("03 00 25 2C 92 12 96 1C") //
         aString.append("92 12 9A 1C 00 3C 3F 40") //
         aString.append("33 05 3F 53 FE 2F A2 B3") //
         aString.append("22 01 15 28 3F 40 4E C3") //
         aString.append("03 43 0B 43 3F 53 3B 63") //
         aString.append("FD 2F B2 B0 10 00 22 01") //
         aString.append("07 28 B2 B0 00 02 00 08") //
         aString.append("03 2C 92 12 70 1C 07 3C") //
         aString.append("7C 40 0A 00 02 3C 7C 40") //
         aString.append("0B 00 92 12 8C 1C 92 12") //
         aString.append("58 1C A2 D2 00 08 32 D2") //
         aString.append("30 40 6E 5F 30 41 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("FF FF 84 FD 25 00 9A FC") //
         aString.append("14 00 50 FC 19 00 20 FC") //
         aString.append("03 00 5F F5 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 AB AB 4A FB") //
         aString.append("E2 00 3C FA E1 00 AE FB") //
         aString.append("AB AB 2C 5A A4 00 CA FB") //
         aString.append("A3 00 56 5A A2 00 BA F9") //
         aString.append("A1 00 24 57 A0 00 AB AB") //
         aString.append("00 00 00 00 FF FF FF FF") //
         aString.append("20 00 71 62 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 AE 5C 00 00 A8 57") //
         aString.append("00 00 28 4E 68 45 00 00") //
         aString.append("DC 5F AE 5A 7A 5A DA 50") //
         */
        sensorData.append(aString)
        
        
        // # ID: E0:07:A0:00:00:46:5C:54
        // # Memory content: Sensor 4
        aString = String()
        aString.append("85 44 88 53 05 00 03 95") // 0x00
        aString.append("51 04 65 54 00 00 00 00") // 0x01
        aString.append("00 00 00 00 00 00 00 00") // 0x02
        aString.append("F5 D6 04 10 16 00 C0 4A") // 0x03
        aString.append("67 80 16 00 C0 46 A7 80") // 0x04
        aString.append("16 00 C0 46 A7 80 16 00") // 0x05
        aString.append("C0 46 A7 80 15 00 C0 4A") // 0x06
        aString.append("A7 80 16 00 C0 4A 67 80") // 0x07
        aString.append("15 00 C0 4A A7 80 16 00") // 0x08
        aString.append("C0 4A 67 80 16 00 C0 46") // 0x09
        aString.append("A7 80 16 00 C0 46 A7 80") // 0x0a
        aString.append("16 00 C0 46 A7 80 15 00") // 0x0b
        aString.append("C0 46 A7 80 15 00 C0 46") // 0x0c
        aString.append("A7 80 16 00 C0 46 67 80") // 0x0d
        aString.append("15 00 C0 46 67 80 16 00") // 0x0e
        aString.append("C0 46 67 80 00 00 C0 CE") // 0x0f
        aString.append("A7 80 00 00 C0 B6 A7 80") // 0x10
        aString.append("00 00 C0 BA A7 80 00 00") // 0x11
        aString.append("C0 BE A7 80 00 00 C0 BE") // 0x12
        aString.append("A7 80 00 00 C0 AA A7 80") // 0x13
        aString.append("00 00 C0 8E A7 80 00 00") // 0x14
        aString.append("C0 8A 67 80 00 00 C0 7E") // 0x15
        aString.append("A7 80 00 00 C0 72 A7 80") // 0x16
        aString.append("00 00 C0 66 A7 80 00 00") // 0x17
        aString.append("C0 5E 67 80 00 00 C0 56") // 0x18
        aString.append("A7 80 00 00 C0 4E A7 80") // 0x19
        aString.append("00 00 C0 4A 67 80 00 00") // 0x1a
        aString.append("C0 46 67 80 00 00 C0 CA") // 0x1b
        aString.append("A7 80 00 00 C0 C6 A7 80") // 0x1c
        aString.append("00 00 C0 C6 A7 80 00 00") // 0x1d
        aString.append("C0 C6 A7 80 00 00 C0 C6") // 0x1e
        aString.append("A7 80 00 00 C0 CA A7 80") // 0x1f
        aString.append("00 00 C0 CE A7 80 00 00") // 0x20
        aString.append("C0 CE A7 80 00 00 C0 D2") // 0x21
        aString.append("A7 80 00 00 C0 DA 67 80") // 0x22
        aString.append("00 00 C0 D6 A7 80 00 00") // 0x23
        aString.append("C0 CA A7 80 00 00 C0 CE") // 0x24
        aString.append("A7 80 00 00 C0 D2 A7 80") // 0x25
        aString.append("00 00 C0 D6 A7 80 00 00") // 0x26
        aString.append("C0 DA A7 80 65 54 00 00") // 0x27
        aString.append("D5 75 00 01 D3 04 95 51") //
        aString.append("14 07 96 80 5A 00 ED A6") //
        aString.append("12 9C 1A C8 04 A3 69 68") //
        /*
         aString.append("9E 42 21 83 F2 90 07 00") //
         aString.append("06 08 02 24 0C 43 17 3C") //
         aString.append("C2 43 08 08 B2 40 DF 00") //
         aString.append("08 08 D2 42 A2 F9 08 08") //
         aString.append("D2 42 A3 F9 08 08 0C 41") //
         aString.append("0C 53 92 12 90 1C 5C 93") //
         aString.append("03 20 A2 41 08 08 02 3C") //
         aString.append("B2 43 08 08 1C 43 21 53") //
         aString.append("30 41 0A 12 4A 4C 4C 93") //
         aString.append("0B 20 B2 40 50 CC 02 07") //
         aString.append("92 D3 00 07 B2 C0 00 02") //
         aString.append("00 07 A2 D2 00 07 02 3C") //
         aString.append("92 12 82 1C 32 D0 D8 00") //
         aString.append("E2 B3 C3 1C 09 28 E2 C3") //
         aString.append("C3 1C 4A 93 05 24 12 C3") //
         aString.append("12 10 A4 1C 12 11 A4 1C") //
         aString.append("3A 41 30 41 0A 12 0B 12") //
         aString.append("08 12 09 12 06 12 F2 90") //
         aString.append("07 00 06 08 68 20 B0 12") //
         aString.append("3A FB 61 20 92 12 78 1C") //
         aString.append("3A 40 FA F9 4C 43 8A 12") //
         aString.append("3B 40 84 1C 26 4B 38 40") //
         aString.append("B0 F9 39 40 A4 1C B2 90") //
         aString.append("00 20 A4 1C 09 2C 1F 43") //
         aString.append("B0 12 30 FB 3F 40 00 20") //
         aString.append("2F 89 82 4F A4 1C 06 3C") //
         aString.append("0F 43 B0 12 30 FB B2 50") //
         aString.append("00 E0 A4 1C 92 52 A4 1C") //
         aString.append("A4 1C 2F 49 7E 42 0D 43") //
         aString.append("0C 48 AB 12 1F 43 5E 43") //
         aString.append("3D 40 22 00 0C 48 AB 12") //
         aString.append("B2 90 00 01 A4 1C 08 28") //
         aString.append("7F 43 7E 42 0D 43 0C 48") //
         aString.append("AB 12 7C 40 34 00 29 3C") //
         aString.append("6C 42 8A 12 2F 49 3F F0") //
         aString.append("FF 07 82 4F A6 1C 1F 42") //
         aString.append("A6 1C 7E 40 0B 00 3D 40") //
         aString.append("16 00 0C 48 AB 12 7C 40") //
         aString.append("05 00 8A 12 2F 49 7E 40") //
         aString.append("0C 00 3D 40 28 00 0C 48") //
         aString.append("AB 12 7C 40 06 00 8A 12") //
         aString.append("2F 49 7E 40 0C 00 3D 40") //
         aString.append("34 00 0C 48 AB 12 B2 B0") //
         aString.append("10 00 22 01 06 2C 7C 40") //
         aString.append("28 00 92 12 8C 1C 0C 43") //
         aString.append("05 3C E2 C2 C3 1C 92 12") //
         aString.append("94 1C 1C 43 30 40 6C 5F") //
         aString.append("5E 43 3D 40 21 00 0C 48") //
         aString.append("00 46 C2 43 08 08 E2 D2") //
         aString.append("C3 1C 92 12 98 1C 4C 93") //
         aString.append("30 41 F2 90 07 00 06 08") //
         aString.append("02 24 0C 43 30 41 B0 12") //
         aString.append("3A FB 08 24 A2 43 DC F8") //
         aString.append("7C 40 28 00 92 12 8C 1C") //
         aString.append("0C 43 30 41 92 12 78 1C") //
         aString.append("92 D3 00 07 B2 40 4B D8") //
         aString.append("02 07 B2 C0 00 02 00 07") //
         aString.append("A2 D2 00 07 92 43 DC F8") //
         aString.append("32 D0 D8 00 E2 B3 C3 1C") //
         aString.append("05 28 E2 C3 C3 1C 92 42") //
         aString.append("A4 1C DE F8 5C 43 92 12") //
         aString.append("86 1C E2 C2 C3 1C 92 12") //
         aString.append("94 1C 1C 43 30 41 F2 90") //
         aString.append("07 00 06 08 02 24 0C 43") //
         aString.append("30 41 C2 43 08 08 E2 D2") //
         aString.append("C3 1C 92 12 72 1C 1C 43") //
         aString.append("30 41 0A 12 92 12 20 1C") //
         aString.append("4C 93 14 24 F2 90 05 00") //
         aString.append("0C 08 10 20 1D 42 06 08") //
         aString.append("5F 42 06 08 0D 93 07 20") //
         aString.append("7F 93 05 20 92 12 94 1C") //
         aString.append("C2 43 08 08 12 3C 7F 90") //
         aString.append("10 00 02 28 0C 43 0E 3C") //
         aString.append("C2 43 08 08 0C 43 07 3C") //
         aString.append("0E 4C 0E 5E 0A 4D 0A 5E") //
         aString.append("A2 4A 08 08 1C 53 0C 9F") //
         aString.append("F7 2B 1C 43 3A 41 30 41") //
         aString.append("0A 12 4A 4C B0 12 C8 5B") //
         aString.append("6A 92 10 20 7E 40 0B 00") //
         aString.append("3D 40 16 00 3C 40 B0 F9") //
         aString.append("92 12 4C 1C 82 4C A6 1C") //
         aString.append("92 52 A6 1C A6 1C 92 52") //
         aString.append("A6 1C A6 1C 3A 41 30 41") //
         aString.append("0E 43 1C 42 B6 F9 B0 12") //
         aString.append("DE 5E 1D 42 AA 1C 12 C3") //
         aString.append("0D 10 0D 11 0C 9D 02 2C") //
         aString.append("0D 8C 04 3C 0C 8D 0D 4C") //
         aString.append("3E 40 00 02 3D 90 00 02") //
         aString.append("02 28 3D 40 FF 01 5F 42") //
         aString.append("A8 F9 0F 9D 06 2C B2 D0") //
         aString.append("40 00 AE 1C F2 D0 40 00") //
         aString.append("C2 1C 0D DE 82 4D AA 1C") //
         aString.append("30 41 0A 12 0B 12 08 12") //
         aString.append("09 12 5B 42 A9 F9 48 43") //
         aString.append("C2 93 64 F8 09 34 F2 C0") //
         aString.append("80 00 64 F8 6B B2 01 28") //
         aString.append("58 43 4C 43 92 12 86 1C") //
         aString.append("59 42 64 F8 0A 3C 6A 93") //
         aString.append("04 20 B2 B0 00 02 00 08") //
         aString.append("04 28 7C 40 06 00 92 12") //
         aString.append("88 1C 1A 42 9E 01 4A 93") //
         aString.append("1F 24 4E 49 6E 83 7E 90") //
         aString.append("03 00 F7 2F 7A 90 10 00") //
         aString.append("02 20 58 B3 12 2C 4C 4A") //
         aString.append("7C 50 11 00 92 12 60 1C") //
         aString.append("5B B3 03 28 7A 90 06 00") //
         aString.append("E8 27 6B B3 03 28 7A 90") //
         aString.append("0E 00 E3 27 7A 90 10 00") //
         aString.append("D6 23 58 B3 DE 2F D9 3F") //
         aString.append("5E 42 64 F8 6E 83 7E 90") //
         aString.append("03 00 25 2C 92 12 96 1C") //
         aString.append("92 12 9A 1C 00 3C 3F 40") //
         aString.append("33 05 3F 53 FE 2F A2 B3") //
         aString.append("22 01 15 28 3F 40 4E C3") //
         aString.append("03 43 0B 43 3F 53 3B 63") //
         aString.append("FD 2F B2 B0 10 00 22 01") //
         aString.append("07 28 B2 B0 00 02 00 08") //
         aString.append("03 2C 92 12 70 1C 07 3C") //
         aString.append("7C 40 0A 00 02 3C 7C 40") //
         aString.append("0B 00 92 12 8C 1C 92 12") //
         aString.append("58 1C A2 D2 00 08 32 D2") //
         aString.append("30 40 6E 5F 30 41 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("FF FF 84 FD 25 00 9A FC") //
         aString.append("14 00 50 FC 19 00 20 FC") //
         aString.append("03 00 5F F5 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 00 00 AB AB 4A FB") //
         aString.append("E2 00 3C FA E1 00 AE FB") //
         aString.append("AB AB 2C 5A A4 00 CA FB") //
         aString.append("A3 00 56 5A A2 00 BA F9") //
         aString.append("A1 00 24 57 A0 00 AB AB") //
         aString.append("00 00 00 00 FF FF FF FF") //
         aString.append("20 00 71 62 00 00 00 00") //
         aString.append("00 00 00 00 00 00 00 00") //
         aString.append("00 00 AE 5C 00 00 A8 57") //
         aString.append("00 00 28 4E 68 45 00 00") //
         aString.append("DC 5F AE 5A 7A 5A DA 50") //
         */
//        sensorData.append(aString)
        return sensorData

    }
}

