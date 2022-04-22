using NLog;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ShipListReader
{
    public class Utilities
    {
        private static Logger Log = LogManager.GetCurrentClassLogger();
        public static FileInfo GetSourceFile()
        {
            var sourceFile = new FileInfo("temp");
            DirectoryInfo info = new DirectoryInfo(ConfigurationManager.AppSettings["FilesDir"]);
            FileInfo[] files = info.GetFiles().OrderBy(p => p.CreationTime).ToArray();
            foreach (FileInfo file in files)
            {
                if (file.Name.Equals(ConfigurationManager.AppSettings["SourceFileName"]))
                {
                    Log.Info("Found ship list file to process, filename is {0}", file.Name);
                    return file;
                }
            }
            return null;
        }

        public static string GetSeedsFileLine(Dictionary<string, string> seedInfo)
        {
            var sb = new StringBuilder();
            //RsiUser.create(name: 'OPSCHIEF', title: 'Member-Owner', link: '')
            // manufacturers: SELECT id, name, description, origin_location, created_at, updated_at, logo FROM public.manufacturers;

            Dictionary<string, string>.KeyCollection keys = seedInfo.Keys;
            sb.Append("Ships.create(");
            bool isFirst = true;
            foreach (string columnName in keys)
            {
                if (!isFirst)
                    sb.Append(", ");
                sb.Append(columnName);
                sb.Append(": '");
                sb.Append(seedInfo.GetValueOrDefault(columnName));
                sb.Append("'");
                isFirst = false;
            }
            sb.Append(")");
            return sb.ToString();
        }

        public static string GetMFRFileLine(Dictionary<int, string> mfrInfo)
        {
            var sb = new StringBuilder();
            //RsiUser.create(name: 'OPSCHIEF', title: 'Member-Owner', link: '')
            // manufacturers: SELECT id, name, description, origin_location, created_at, updated_at, logo FROM public.manufacturers;

            Dictionary<int, string>.KeyCollection keys = mfrInfo.Keys;
            foreach (int key in keys)
            {
                sb.Append("Manufacturers.create(");
                sb.Append("id: '");
                sb.Append(key);
                sb.Append("', name: '");
                sb.Append(mfrInfo.GetValueOrDefault(key));
                sb.AppendLine("', description: '', origin_location: '', created_at: '', updated_at: '', logo: '')");
            }
            return sb.ToString();
        }
    }
}
