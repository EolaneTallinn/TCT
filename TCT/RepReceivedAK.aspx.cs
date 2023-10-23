using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Text;
using System.Text.RegularExpressions;

namespace TCT
{
    public partial class RepReceivedAK : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }

        protected void GridViewReport_RowDataBound(object sender, GridViewRowEventArgs e)
        {
            if (e.Row.RowType == DataControlRowType.DataRow)
            {
                //
            }
        }

        protected void ExportButton_Click(object sender, EventArgs e)
        {
            Response.Clear();
            Response.Buffer = true;
            string filename = string.Format("GateregExport_{0:yyyyMMdd HHmmss}.csv", DateTime.Now);
            Response.AddHeader("content-disposition", string.Format("attachment;filename={0}", filename));
            Response.Charset = "UTF-8";
            Response.ContentType = "application/text";
            GridViewReport.AllowPaging = false;
            GridViewReport.DataBind();

            StringBuilder Columnbind = new StringBuilder();
            for (int k = 0; k < GridViewReport.Columns.Count; k++)
            {
                Columnbind.Append(GridViewReport.Columns[k].HeaderText + '\t');
            }

            Columnbind.Append("\r\n");
            for (int i = 0; i < GridViewReport.Rows.Count; i++)
            {
                for (int k = 0; k < GridViewReport.Columns.Count; k++)
                {

                    string CellText = GridViewReport.Rows[i].Cells[k].Text;
                    string normalisedCellText = Regex.Replace(CellText, @"<[^>]+>|&nbsp;", "").Trim();
                    Columnbind.Append(normalisedCellText + '\t');
                }

                Columnbind.Append("\r\n");
            }
            Response.Output.Write(Columnbind.ToString());
            Response.Flush();
            Response.End();
        }  

    }
}