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
    public partial class RepGateReg : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }

        protected void GridViewReport_5_RowDataBound(object sender, GridViewRowEventArgs e)
        {
            if (e.Row.RowType == DataControlRowType.DataRow)
            {
                // The Attachments column in GridViewReport_5 is originally just a comma separated list of links
                // The below code will "re-format" it into a list of nice HTML links
                string Attachments = DataBinder.Eval(e.Row.DataItem, "Attachments").ToString();
                if (Attachments != string.Empty)
                {
                    // string[] Docs = Attachments.Split(',');
                    // foreach (string Doc in Docs) { }
                    Repeater rptInner = (Repeater)e.Row.FindControl("RepeaterReport_Inner");
                    rptInner.DataSource = Attachments.Split(',');
                    rptInner.DataBind();
                }
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
           GridViewReport_5.AllowPaging = false;
           GridViewReport_5.DataBind();

           StringBuilder Columnbind = new StringBuilder();
           for (int k = 0; k < GridViewReport_5.Columns.Count; k++)
           {
               Columnbind.Append(GridViewReport_5.Columns[k].HeaderText + '\t');
           }

           Columnbind.Append("\r\n");
           for (int i = 0; i < GridViewReport_5.Rows.Count; i++)
           {
               for (int k = 0; k < GridViewReport_5.Columns.Count; k++)
               {
                   string CellText = GridViewReport_5.Rows[i].Cells[k].Text;
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