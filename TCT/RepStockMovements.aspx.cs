using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace TCT
{
    public partial class RepStockMovements : System.Web.UI.Page
    {

        protected void Page_Load(object sender, EventArgs e)
        {

        }

        protected void GridViewReport_4_RowDataBound(object sender, GridViewRowEventArgs e)
        {
            if (e.Row.RowType == DataControlRowType.DataRow)
            {
                //if (Convert.ToInt32(DataBinder.Eval(e.Row.DataItem, "InnerCount")) < 1)
                //    return;

                string LineID = Convert.ToString(DataBinder.Eval(e.Row.DataItem, "StockID"));
                // string LineID = GridViewReport_5.DataKeys[e.Row.RowIndex].Value.ToString();
                GridView gvInner = (GridView)e.Row.FindControl("GridViewReport_Inner");
                SqlDataSource gvInnerDS = (SqlDataSource)e.Row.FindControl("SqlDataSource_Report_Inner");
                gvInnerDS.SelectParameters["LineID"].DefaultValue = LineID;
                gvInner.DataSource = gvInnerDS;
                gvInner.DataBind();

                // Create a JS global array variable to the HTML page
                ClientScript.RegisterArrayDeclaration("LineIDs", String.Concat("'LineID-", LineID, "'"));
            }
        }

    }
}