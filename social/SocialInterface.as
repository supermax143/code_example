package social
{




import flash.display.DisplayObject;
import flash.events.EventDispatcher;
import flash.utils.ByteArray;

import social.common.ResourceType;
import social.common.user.SocialUser;
import social.events.SocialInterfaceEvent;
import social.od.ODSocialInterface;
import social.vk.VKSocialInterface;
	
public class SocialInterface extends EventDispatcher 
{
	//--------------------------------------------------------------------------
    //
    //  Static Methods
    //
    //-------------------------------------------------------------------------

	private static var _instance:SocialInterface;
	
	static public function get instance():SocialInterface
	{
		return _instance;
	}
	
	public static function create(application:DisplayObject):void
	{
		var params:Object = application.loaderInfo.parameters as Object
		switch(int(params.resource))
		{
			case(ResourceType.VK):  		  			
				_instance = new VKSocialInterface(params);   		
				break;
			case(ResourceType.OD):
				_instance = new ODSocialInterface(application) 
				break;
			default:  		  			
				_instance = new VKSocialInterface(params);   		
				break;
		}   
	}
	
	
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //-------------------------------------------------------------------------
	protected var _authKey:String;	
	protected var _viewerID:String;
	protected var _resource:int;
	
	public var inited:Boolean = false;
    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //-------------------------------------------------------------------------

    public function SocialInterface()
    {
        throw new Error("SocialInterface is abstract class");
    }
    //--------------------------------------------------------------------------
    //
    //  Private Methods
    //
    //------------------------------------------------------------------------- 
    
    //--------------------------------------------------------------------------
    //
    //  Public Methods
    //
    //------------------------------------------------------------------------- 
	
    public function updateBalance():void
    {
		throw new Error('updateBalance must be overriden');
    }
	
	public function getUsersProfiles(uids:Array,handler:Function):void
	{
		throw new Error('getUsersProfiles must be overriden');
	}
	
	public function loginUser():void
    {
		throw new Error('loginUser must be overriden');
    }
	
	
	public function showUserPage(user:SocialUser):void
	{
		throw new Error('showUserPage must be overriden');
	}	
	
	
	public function wallPost(image:ByteArray,userId:String,text:String,callback:Function = null):void
	{
		
		throw new Error('wallPost must be overriden');
	}
	
	
	private function showRequestBox(userId:String,message:String):void
	{
		throw new Error('showRequestBox must be overriden');
	}
	
	public function showInviteBox():void
	{
		throw new Error('showInviteBox must be overriden');
	}
	
	public function showPaymentBox(itemInfo:Object,currency:String,handler:Function):void
	{
		throw new Error('showPaymentBox must be overriden');
	}
    //--------------------------------------------------------------------------
    //
    //  Public Properties
    //
    //------------------------------------------------------------------------- 
	public function get errorMessageURL():String
	{
		return "";
	}
	
	public function get vieverId():String
	{
		return "-1";
	}
	
	
	public function get authKey():String
	{
		return "-1";
	}

	
	public function get resource():int
	{
		return _resource;  
		
	}

	public function set resource(value:int):void
	{
		_resource = value;
	}

	public function get nastiaID():String
	{
		return 'unknown';
	}
}	
}