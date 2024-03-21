package momo;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class ResultMoMo {
	public String t;
	public String partnerCode;
	public String requestId;
	public String deeplink;
	public String deeplinkMiniApp;
	public String orderId;
	public String amount;
	public String responseTime;
	public String message;
	public String resultCode;
	public String payUrl;
	public String qrCodeUrl;
}
