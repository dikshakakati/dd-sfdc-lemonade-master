/**
 * @description Generic class to generate response body for all inbound integrations.
 */
public class GenericRESTResourceResponseBody {
    /**
     * @description Integer value to indicate status code.
     */
    public Integer statusCode { get; set; }
    /**
     * @description String value to indicate success or failure.
     */
    public Boolean successful { get; set; }
    /**
     * @description String value to pass success/error message.
     */
    public String message { get; set; }
}