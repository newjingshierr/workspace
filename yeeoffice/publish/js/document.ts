import {AkRequest, AkResponse, Request} from "akmii-yeeoffice-common";
import {DocumentAddRequest, DocumentFavouriteRequest,DocumentAddFavouriteRequest,DocumentDeleteAPIRequest,LibraryRecycleBinDocModelRequest} from "./model/request/document";
import {DocumentFavouritesResponse,LibraryRecycleBinDocModelResponse,DocumentRenameResponse} from "./model/response/document";
import {DocumentMyUploadsResponse, DocumentMyDeletedResponse} from "./model/response/document";

export default class DocumentAPI {

    static deleteDocument(request: DocumentDeleteAPIRequest) {
       // let url: string = window["YeeOfficeDocument_APIUrl"] + "/YunGalaxyDocument/YunGalaxyDocInfo/DeleteGUIDS";
        let url: string = window["YeeOfficeDocument_APIUrl"] + "/YunGalaxyDocument/YunGalaxyDocInfo/DeleteGUIDS";
        return new Request<AkRequest, AkResponse>().post(url, request);
    }

    static addDocument(request: DocumentAddRequest) {
       //let url: string = window["YeeOfficeDocument_APIUrl"] + "/YunGalaxyDocument/YunGalaxyDocInfo/Item";
        let url: string = "https://192.168.0.210/_API/Ver(1.0)/" + "/YunGalaxyDocument/YunGalaxyDocInfo/Item";
        return new Request<AkRequest, AkResponse>().post(url, request);
    }

    static addFavourite(request:DocumentAddFavouriteRequest) {
       // let url: string =window["YeeOfficeDocument_APIUrl"] + "/YunGalaxyDocument/YunGalaxyDocFavorites/Item";
         let url: string =window["YeeOfficeDocument_APIUrl"] + "/YunGalaxyDocument/YunGalaxyDocFavorites/Item";
        return new Request<AkRequest, AkResponse>().post(url, request);
    }

    static cancelFavourite(request:DocumentAddFavouriteRequest) {
        //let url: string = window["YeeOfficeDocument_APIUrl"] + "/YunGalaxyDocument/YunGalaxyDocInfo/DeleteFavourite";
         let url: string = window["YeeOfficeDocument_APIUrl"] + "/YunGalaxyDocument/YunGalaxyDocInfo/DeleteFavourite";
        return new Request<AkRequest, AkResponse>().post(`${url}?YGDocSPGUID=${request.YGDocSPGUID}`);
    }

    static  GetFavourites(docRequest: DocumentFavouriteRequest): Promise<DocumentFavouritesResponse> {

        //let url: string =window["YeeOfficeDocument_APIUrl"] + "/YunGalaxyDocument/YunGalaxyDocInfo/GetMyFavourite";
         let url: string =window["YeeOfficeDocument_APIUrl"] + "/YunGalaxyDocument/YunGalaxyDocInfo/GetMyFavourite";
        return new Request<DocumentFavouriteRequest, DocumentFavouritesResponse>().post(`${url}?CurrentIndex=${docRequest.CurrentIndex}&PageSize=${docRequest.PageSize}`);
    }

    static  GetMyUploads(docRequest: DocumentFavouriteRequest): Promise<DocumentMyUploadsResponse> {
       //let  url: string = window["YeeOfficeDocument_APIUrl"] + "/YunGalaxyDocument/YunGalaxyDocInfo/MyUpload";
      let  url: string = window["YeeOfficeDocument_APIUrl"] + "/YunGalaxyDocument/YunGalaxyDocInfo/MyUpload";
        return new Request<DocumentFavouriteRequest, DocumentMyUploadsResponse>().post(`${url}`,docRequest);
    }

    static  GetMyDelete(docRequest: DocumentFavouriteRequest): Promise<DocumentMyDeletedResponse> {
      //let url: string =window["YeeOfficeDocument_APIUrl"]+ "/YunGalaxyDocument/YunGalaxyDocInfo/MyDeleted";
        let url: string =window["YeeOfficeDocument_APIUrl"] + "/YunGalaxyDocument/YunGalaxyDocInfo/MyDeleted";
        return new Request<DocumentFavouriteRequest, DocumentMyDeletedResponse>().post(`${url}`,docRequest);
    }
    static  DeleteRecycle(docRequest: LibraryRecycleBinDocModelRequest): Promise<AkResponse>{
      //  let url: string =window["YeeOfficeDocument_APIUrl"]+ "/YunGalaxyDocument/YunGalaxyDocInfo/DeleteRecycleItems";
         let url: string =window["YeeOfficeDocument_APIUrl"] + "/YunGalaxyDocument/YunGalaxyDocInfo/DeleteRecycleItems";
        return new Request<LibraryRecycleBinDocModelRequest, AkResponse>().post(url, docRequest);
    }
    static  RestoreRecycle(docRequest: LibraryRecycleBinDocModelRequest): Promise<AkResponse>{
        //let url: string =window["YeeOfficeDocument_APIUrl"]+ "/YunGalaxyDocument/YunGalaxyDocInfo/RestoreRecycleItems";
          let url: string =window["YeeOfficeDocument_APIUrl"] + "/YunGalaxyDocument/YunGalaxyDocInfo/RestoreRecycleItems";
        return new Request<LibraryRecycleBinDocModelRequest, AkResponse>().post(url, docRequest);
    }
    static  EmptyRecycle(docRequest:AkRequest): Promise<AkResponse>{
        //let url: string =window["YeeOfficeDocument_APIUrl"]+ "/YunGalaxyDocument/YunGalaxyDocInfo/EmptyRecycle";
          let url: string =window["YeeOfficeDocument_APIUrl"] + "/YunGalaxyDocument/YunGalaxyDocInfo/EmptyRecycle";
        return new Request<AkRequest, AkResponse>().post(url, docRequest);
    }

    static  GetFavourite(docRequest:AkRequest): Promise<AkResponse>{
        //let url: string =window["YeeOfficeDocument_APIUrl"]+ "/YunGalaxyDocument/YunGalaxyDocInfo/GetFavouriteStatusByYGDocSPGUIDS";
        let url: string =window["YeeOfficeDocument_APIUrl"] + "/YunGalaxyDocument/YunGalaxyDocInfo/GetFavouriteStatusByYGDocSPGUIDS";
        return new Request<AkRequest, AkResponse>().post(url, docRequest);
    }

    static renameDocument(request: DocumentAddRequest):Promise<DocumentRenameResponse> {
        //let url: string = window["YeeOfficeDocument_APIUrl"] + "/YunGalaxyDocument/YunGalaxyDocInfo/RenameItem";
         let url: string = window["YeeOfficeDocument_APIUrl"] + "/YunGalaxyDocument/YunGalaxyDocInfo/RenameItem";
        return new Request<AkRequest, DocumentRenameResponse>().post(url, request);
    }
}
