import { Request, AkRequest } from "akmii-yeeoffice-common";
import * as _ from 'lodash'
import {
    LibraryCatalogModelListResponse,
    LibraryCatalogModel,
    LibraryModel,
    LibraryResponse,
    LibraryIconResponse,
    LibraryListResponse
} from "./model/response/library";
import { LibrarySearchRequest, LibrarySearchByIdRequest, LibraryRequest, LibraryCatalogDeleteByIDRequest, LibraryCatalogRequest, LibraryCatalogCheckRequest, LibraryIconRequest, LibraryAddRequest, LibraryUpdateRequest, LibraryDeleteRequest, SPLibrarySearchRequest } from "./model/request/library";
import { Req } from "awesome-typescript-loader/dist/checker/protocol";
import LibrarySharePointAPI from "./library-sp";

export class LibraryCatalogAPI {
    serviceUrl: string;
    pagesize: number;
    CurrentIndex: number;
    permissionServiceUrl: string;
    constructor() {
        this.serviceUrl = window["YeeOfficeDocument_APIUrl"] + "/YunGalaxyDocument/YunGalaxyDocPropType";
        this.permissionServiceUrl = window["YeeOfficeDocument_APIUrl"] + "/YunGalaxyDocument/DoclibCompetence";
        //this.serviceUrl = "https://192.168.0.210/_API/Ver(1.0)/YunGalaxyDocument/YunGalaxyDocPropType";
        //this.permissionServiceUrl = "https://192.168.0.210/_API/Ver(1.0)/YunGalaxyDocument/DoclibCompetence";
        this.pagesize = 1000;
        this.CurrentIndex = 0;
    }
    GetLibraryCatalogData(): Promise<LibraryCatalogModelListResponse> {
        var libRequest: AkRequest = {};
        return new Request<AkRequest, LibraryCatalogModelListResponse>().post(this.serviceUrl + "/Items?CurrentIndex=" + this.CurrentIndex + "&PageSize=" + this.pagesize, libRequest);
    }
    AddLibraryCatalog(libRequest: LibraryCatalogRequest): Promise<LibraryCatalogModelListResponse> {
        return new Request<AkRequest, LibraryCatalogModelListResponse>().post(this.serviceUrl + "/Item", libRequest);
    }
    UpdateLibraryCatalog(libRequest: LibraryCatalogRequest): Promise<LibraryCatalogModelListResponse> {

        return new Request<LibraryCatalogRequest, LibraryCatalogModelListResponse>().post(this.serviceUrl + "/Item(" + libRequest.YGDocPropID + ")/Update", libRequest);
    }
    DeleteLibraryCatalog(libRequest: LibraryCatalogDeleteByIDRequest): Promise<LibraryCatalogModelListResponse> {
        return new Request<LibraryCatalogDeleteByIDRequest, LibraryCatalogModelListResponse>().post(this.serviceUrl + "/Item/Delete", libRequest);
    }
    CheckDocLibrary(libRequest: LibraryCatalogCheckRequest): Promise<LibraryCatalogModelListResponse> {
        return new Request<LibraryCatalogCheckRequest, LibraryCatalogModelListResponse>().post(this.serviceUrl + "/CheckDocLibrary", libRequest);
    }
}
export class LibraryAPI {
    serviceUrl: string;
    pagesize: number;
    CurrentIndex: number;
    permissionServiceUrl: string;
    constructor() {
        this.serviceUrl = window["YeeOfficeDocument_APIUrl"] + "/YunGalaxyDocument/YunGalaxyDocLibrary";
        this.permissionServiceUrl = window["YeeOfficeDocument_APIUrl"] + "/YunGalaxyDocument/DoclibCompetence";
          // this.serviceUrl ="https://192.168.0.210/_API/Ver(1.0)/YunGalaxyDocument/YunGalaxyDocLibrary";
            //     this.permissionServiceUrl ="https://192.168.0.210/_API/Ver(1.0)/YunGalaxyDocument/DoclibCompetence";

        this.pagesize = 1000;
        this.CurrentIndex = 0;
    }
    static searchByID(libRequest: LibrarySearchByIdRequest): Promise<LibraryResponse> {

        return new Promise((resolve, reject) => {
            var response: LibraryResponse = {
                Data: null
            };
            resolve(response);
        });
    }

    static search(searchvalue: string): Promise<LibraryListResponse> {

        return new Promise((resolve, reject) => {
            var response: LibraryListResponse = {
                Data: null
            };
            resolve(response);
        });
    }

    AddLibrary(libRequest: LibraryAddRequest): Promise<LibraryResponse> {
        return new Promise((resolve, reject) => {
            LibrarySharePointAPI.Instance.Add(libRequest).then((sp: LibraryResponse) => {
                new Request<LibraryAddRequest, LibraryResponse>().post(this.serviceUrl + "/Item/Add", libRequest).then((d) => {
                    if (d.OperationState) {
                        resolve({ OperationState: true });
                    } else {
                        reject({ OperationState: false });
                    }
                });
            }).catch((sp) => {
                resolve({ OperationState: false, ErrorMessage: sp.ErrorMessage });
            });
        });

    }
    MergeLibrary(libRequest: LibraryUpdateRequest): Promise<LibraryResponse> {
        return new Promise((resolve, reject) => {
            LibrarySharePointAPI.Instance.Update(libRequest).then((a) => {
                new Request<LibraryUpdateRequest, LibraryResponse>().post(this.serviceUrl + "/Item/Update", libRequest).then((d) => {
                    if (d) {
                        resolve({ OperationState: true });
                    } else {
                        resolve({ OperationState: false })
                    }
                });
            }).catch((sp) => {
                resolve({ OperationState: false, ErrorMessage: sp.ErrorMessage });
            });
        });
    }
    DeleteDocLibrary(libRequest: LibraryDeleteRequest): Promise<LibraryResponse> {
        return new Promise((resolve, reject) => {
            LibrarySharePointAPI.Instance.delete(libRequest).then((a) => {
                new Request<LibraryDeleteRequest, LibraryResponse>().post(this.serviceUrl + "/Item/Delete", libRequest).then((d) => {
                    if (d.OperationState) {
                        resolve({ OperationState: true });
                    } else {
                        resolve({ OperationState: false })
                    }
                });
            }).catch((sp) => {
                resolve({ OperationState: false, ErrorMessage: sp.ErrorMessage });
            });
        });
    }

    SearchLibrary(libRequest: LibrarySearchRequest): Promise<LibraryListResponse> {
        if (libRequest.categoryId == undefined) {
            libRequest.categoryId = '';
        }
        if (libRequest.search_value == undefined) {
            libRequest.search_value = '';
        }
        return new Promise((resolve, reject) => {

            new Request<LibrarySearchRequest, LibraryListResponse>().
                post(this.serviceUrl + "/Items?CurrentIndex=" + this.CurrentIndex + "&PageSize=" + this.pagesize + "&YGDocPropID="
                + libRequest.categoryId + "&YGDocLibName=" + encodeURIComponent(libRequest.search_value) + "&OrderBy=" +
                libRequest.OrderBy).then((d) => {
                    // console.log(d);
                    LibrarySharePointAPI.Instance.searchLib().then((lists) => {
                        var data = [];
                        // console.log(lists);
                        var spdata = [];
                        //获取SP数据
                        while (lists.moveNext()) {
                            var currentItem = lists.get_current();
                            let item = { HasPermission: true, TotalNum: currentItem.get_itemCount(), YGDocLibGUID: currentItem.get_id().ToSerialized() };
                            spdata.push(item);
                        }
                        //为了防止排序错误，新建循环使用
                        d.Data.forEach((item) => {
                            spdata.forEach((s) => {
                                if (item.YGDocLibGUID == s.YGDocLibGUID) {
                                    item.HasPermission = s.HasPermission;
                                    item.TotalNum = s.TotalNum;
                                    data.push(item);
                                }
                            });
                        });
                        resolve({ Data: data })
                    }).catch((e) => {
                        // console.log(e);
                        resolve({ Data: [] })
                    });
                }).catch((e) => {
                    //console.log(e);
                    resolve({ Data: [] })
                })

        });

    }

    SearchLibrayByID(libRequest: LibrarySearchByIdRequest): Promise<LibraryResponse> {
        return new Request<LibrarySearchByIdRequest, LibraryResponse>().post(this.serviceUrl + "/Item",libRequest);
    }

    GetLibraryDetails(libReuest: LibraryRequest): Promise<LibraryResponse> {
        return new Request<LibraryRequest, LibraryResponse>().post(this.serviceUrl + "/ItemsDetail(" + libReuest.ID + ")");
    }

    AddLibraryManager(libRequest: LibraryRequest): Promise<LibraryResponse> {
        return new Request<LibraryRequest, LibraryResponse>().post(this.serviceUrl + "/LibOwnerItem", libRequest);
    }
}
