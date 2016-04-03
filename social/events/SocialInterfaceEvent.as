package social.events
{
	import flash.events.Event;
	
	import social.common.user.SocialUser;

public class SocialInterfaceEvent extends Event
{
	public static const LOGIN_USER:String = "login_user";
	public static const ADVERTISEMENTS_READY:String = "advertisements_ready";
	public static const INTERFACE_INITED:String = "interface_inited";
	public static const INTERFACE_NOT_INITED:String = "interface_not_inited";
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------	
    
    public var data:Object;
    
    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------		
	
	public function SocialInterfaceEvent(type:String, data:Object = null, bubbles:Boolean=true, cancelable:Boolean=false)
	{
		super(type,bubbles,cancelable);
		this.data = data;
		
	}
	
	override public function clone():Event {
            return new SocialInterfaceEvent(type, data, bubbles, cancelable);
    }
}
}