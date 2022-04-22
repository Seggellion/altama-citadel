using NLog;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;

namespace ShipListReader
{
    
    public class Program
    {
        public static Logger Log = LogManager.GetCurrentClassLogger();
        static void Main(string[] args)
        {
            var todaysDate = DateTime.Now.ToString("yyyyMMdd");
            int counter = 0;
            string line;
            var watch = new Stopwatch();
            watch.Start();
            
            //Source File Setup
            StreamReader file;
            var sourceFile = Utilities.GetSourceFile();
            file = new StreamReader(sourceFile.FullName);

            //Output Files Setup
            var shipOutputFileStream = new FileStream(ConfigurationManager.AppSettings["FilesDir"] + ConfigurationManager.AppSettings["ShipOutputFileName"], FileMode.Create);
            var shipOutputStreamWriter = new StreamWriter(shipOutputFileStream, Encoding.ASCII);
            var mfrOutputFileStream = new FileStream(ConfigurationManager.AppSettings["FilesDir"] + ConfigurationManager.AppSettings["MFROutputFileName"], FileMode.Create);
            var mfrOutputStreamWriter = new StreamWriter(mfrOutputFileStream, Encoding.ASCII);

            Log.Debug("Reading file..");

            Dictionary<int, string> manufacturerList = new Dictionary<int, string>();
            Dictionary<string, int> manufacturerListByName = new Dictionary<string, int>();
            Dictionary<string, string> SeedInfo = new Dictionary<string, string>();

            var manufacturerId = 0;
            var lastLineLength = 0;

            while ((line = file.ReadLine()) != null)
            {
                string lineCopy = line;
                List<string> fields = Regex.Split(lineCopy, @"\t").ToList();
                Log.Debug("Total fields on this line: {0}", fields.Count);
                if (lineCopy.Length > 20 && lastLineLength > 20)
                {
                    // we only hit this if MSRP is missing
                    SeedInfo.Add("msrp", "");
                    var seedFileLine = Utilities.GetSeedsFileLine(SeedInfo);
                    Log.Info(seedFileLine);
                    shipOutputStreamWriter.WriteLine(seedFileLine);
                    counter++;
                }
                if (lineCopy.Length > 20)
                {
                    SeedInfo.Clear();
                    SeedInfo.Add("model", fields[0]);

                    if (!manufacturerList.ContainsValue(fields[1]))
                    {
                        manufacturerId++;
                        manufacturerList.Add(manufacturerId, fields[1]);
                        manufacturerListByName.Add(fields[1], manufacturerId);
                    }
                    SeedInfo.Add("manufacturer_id", manufacturerListByName.GetValueOrDefault(fields[1]).ToString());
                    SeedInfo.Add("scu", fields[9]);
                    SeedInfo.Add("crew", fields[6]);

                    List<string> dimensions = Regex.Split(fields[7], @"x").ToList();
                    if (dimensions.Count > 2)
                    {
                        SeedInfo.Add("length", dimensions[0]);
                        SeedInfo.Add("beam", dimensions[1]);
                        SeedInfo.Add("height", dimensions[2]);
                    }
                    else
                    {
                        SeedInfo.Add("length", "");
                        SeedInfo.Add("beam", "");
                        SeedInfo.Add("height", "");
                    }
                    SeedInfo.Add("mass", fields[8]);
                    SeedInfo.Add("hyd_fuel_capacity", fields[16]);
                    SeedInfo.Add("qnt_fuel_capacity", fields[17]);

                    SeedInfo.Add("type", fields[2]);

                    SeedInfo.Add("career", fields[3]);
                    SeedInfo.Add("role", fields[4]);
                    SeedInfo.Add("size", fields[5]);

                    SeedInfo.Add("hp", fields[10]);
                    SeedInfo.Add("speed", fields[11]);
                    SeedInfo.Add("afterburner_speed", fields[12]);
                    SeedInfo.Add("ifcs_pitch_max", fields[13]);
                    SeedInfo.Add("ifcs_yaw_max", fields[14]);
                    SeedInfo.Add("ifcs_roll_max", fields[15]);

                    SeedInfo.Add("shield_face_type", fields[18]);
                    SeedInfo.Add("armor_physical_dmg_reduction", fields[19]);
                    SeedInfo.Add("armor_energy_dmg_reduction", fields[20]);
                    SeedInfo.Add("armor_distortion_dmg_reduction", fields[21]);
                    SeedInfo.Add("armor_em_signal_reduction", fields[22]);
                    SeedInfo.Add("armor_ir_signal_reduction", fields[23]);
                    SeedInfo.Add("armor_cs_signal_reduction", fields[24]);
                    SeedInfo.Add("capacitor_crew_load", fields[25]);
                    SeedInfo.Add("capacitor_crew_regen", fields[26]);
                    SeedInfo.Add("capacitor_turret_load", fields[27]);
                    SeedInfo.Add("capacitor_turret_regen", fields[28]);

                }
                else if (lineCopy.Length < 20)
                {
                    //Update baseprice for ship from last line
                    SeedInfo.Add("msrp", lineCopy);
                    var seedFileLine = Utilities.GetSeedsFileLine(SeedInfo);
                    Log.Info(seedFileLine);
                    shipOutputStreamWriter.WriteLine(seedFileLine);
                    counter++;
                }
                lastLineLength = lineCopy.Length;
            }
            file.Close();
            shipOutputStreamWriter.Flush();
            shipOutputStreamWriter.Close();

            var mfrFileLine = Utilities.GetMFRFileLine(manufacturerList);
            mfrOutputStreamWriter.Write(mfrFileLine);
            mfrOutputStreamWriter.Flush();
            mfrOutputStreamWriter.Close();

            watch.Stop();
            Log.Info("ShipListReader processed {0} ship records and completed at:{1}", counter, DateTime.Now);
        }
    }
}
