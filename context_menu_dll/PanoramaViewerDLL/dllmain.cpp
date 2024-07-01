#include "pch.h"
#include <atlfile.h>
#include <atlstr.h>
#include <shobjidl_core.h>
#include <string>
#include <filesystem>
#include <sstream>
#include <Shlwapi.h>
#include <vector>
#include <wil\resource.h>
#include <wil\win32_helpers.h>
#include <wil\stl.h>
#include <wrl/module.h>
#include <wrl/implements.h>
#include <wrl/client.h>
#include <mutex>
#include <thread>
#include <shellapi.h>

using namespace Microsoft::WRL;

HINSTANCE g_hInst = 0;

BOOL APIENTRY DllMain(HMODULE hModule,
    DWORD  ul_reason_for_call,
    LPVOID lpReserved
)
{
    switch (ul_reason_for_call)
    {
    case DLL_PROCESS_ATTACH:
        g_hInst = hModule;
        break;
    case DLL_THREAD_ATTACH:
    case DLL_THREAD_DETACH:
    case DLL_PROCESS_DETACH:
        break;
    }
    return TRUE;
}

// This function is for to get out flutter application folder. It also comes from microsoft.
// https://github.com/microsoft/PowerToys/blob/3443c73d0e81a958974368763631035f3e510653/src/common/utils/process_path.h
inline std::wstring get_module_folderpath(HMODULE mod = nullptr, const bool removeFilename = true)
{
    wchar_t buffer[MAX_PATH + 1];
    DWORD actual_length = GetModuleFileNameW(mod, buffer, MAX_PATH);
    if (GetLastError() == ERROR_INSUFFICIENT_BUFFER)
    {
        const DWORD long_path_length = 0xFFFF; // should be always enough
        std::wstring long_filename(long_path_length, L'\0');
        actual_length = GetModuleFileNameW(mod, (LPWSTR)long_filename.data(), long_path_length);
        PathRemoveFileSpecW((LPWSTR)long_filename.data());
        long_filename.resize(std::wcslen(long_filename.data()));
        long_filename.shrink_to_fit();
        return long_filename;
    }

    if (removeFilename)
    {
        PathRemoveFileSpecW(buffer);
    }
    return { buffer, (UINT)lstrlenW(buffer) };
}
//                     ᐯ  This is the "clsid" you need to pass into your context_menu command configuration. YOU NEED TO CHANGE UUID WITH YOURS. GENERATE A NEW ONE.
class __declspec(uuid("4F996161-1319-44B8-BC22-ED05C5081D87")) YourAppMenuCommand final : public RuntimeClass<RuntimeClassFlags<ClassicCom>, IExplorerCommand, IObjectWithSite>
{ //                                                      ᐱ This is the "id" you need to pass into your context menu command configuration
public:
    //                                        ᐯ Change that line with what do you want to show on context menu
    virtual const wchar_t* Title() { return L"Open with Spheroscopic"; };
    virtual const EXPCMDFLAGS Flags() { return ECF_DEFAULT; }
    virtual const EXPCMDSTATE State(_In_opt_ IShellItemArray* selection) { return ECS_ENABLED; }

    IFACEMETHODIMP GetTitle(_In_opt_ IShellItemArray* items, _Outptr_result_nullonfailure_ PWSTR* name)
    {
        *name = nullptr;
        //                 ᐯ Change that line with what do you want to show on context menu
        return SHStrDupW(L"Open with Spheroscopic", name);
    }
    IFACEMETHODIMP GetIcon(_In_opt_ IShellItemArray*, _Outptr_result_nullonfailure_ PWSTR* icon)
    {
        std::wstring iconResourcePath = get_module_folderpath(g_hInst);
        // this is what icon will shown on context menu. Add your ico file on your assets (on flutter side) and dont forget adding it to the pubspec file
        // '\data\flutter_assets' is the exact location where flutter put your assets for your application.
        //                    ᐯ also dont forget to change icon name
        iconResourcePath += L"\\data\\flutter_assets\\assets\\img\\Logo.ico";
        return SHStrDup(iconResourcePath.c_str(), icon);
    }
    IFACEMETHODIMP GetToolTip(_In_opt_ IShellItemArray*, _Outptr_result_nullonfailure_ PWSTR* infoTip) { *infoTip = nullptr; return E_NOTIMPL; }
    IFACEMETHODIMP GetCanonicalName(_Out_ GUID* guidCommandName) { *guidCommandName = GUID_NULL;  return S_OK; }
    IFACEMETHODIMP GetState(_In_opt_ IShellItemArray* selection, _In_ BOOL okToBeSlow, _Out_ EXPCMDSTATE* cmdState)
    {
        if (nullptr == selection) {
            *cmdState = ECS_HIDDEN;
            return S_OK;
        }

        *cmdState = ECS_ENABLED;
        return S_OK;
    }
    // This is the function will be called when user clicked to the item
    // What we basically do here is just getting file/directory paths where/what user selected and send them to our flutter application (with arguments)
    // So as you can imagine this will open another instance of your app. If you don't want that search for what ipc is.
    IFACEMETHODIMP Invoke(_In_opt_ IShellItemArray* selection, _In_opt_ IBindCtx*) noexcept try
    {
        HWND parent = nullptr;
        if (m_site)
        {
            ComPtr<IOleWindow> oleWindow;
            RETURN_IF_FAILED(m_site.As(&oleWindow));
            RETURN_IF_FAILED(oleWindow->GetWindow(&parent));
        }

        std::wostringstream itemPaths;

        if (selection)
        {
            DWORD count = 0;
            selection->GetCount(&count);

            for (DWORD i = 0; i < count; i++)
            {
                IShellItem* shellItem;
                selection->GetItemAt(i, &shellItem);
                LPWSTR itemName;
                // Retrieves the entire file system path of the file from its shell item
                shellItem->GetDisplayName(SIGDN_FILESYSPATH, &itemName);
                CString fileName(itemName);
                itemPaths << L"\"" << std::wstring(fileName) << L"\"" << L" ";
            }

            std::wstring executablePath = get_module_folderpath(g_hInst);
            //                    ᐯ YOU NEED TO CHANGE THIS NAME WITH YOUR APPLICATION
            executablePath += L"\\Spheroscopic.exe";
            ShellExecute(NULL, L"open", executablePath.c_str(), itemPaths.str().c_str(), get_module_folderpath(g_hInst).c_str(), SW_SHOWDEFAULT);
        }


        return S_OK;
    }
    CATCH_RETURN();

    IFACEMETHODIMP GetFlags(_Out_ EXPCMDFLAGS* flags) { *flags = Flags(); return S_OK; }
    IFACEMETHODIMP EnumSubCommands(_COM_Outptr_ IEnumExplorerCommand** enumCommands) { *enumCommands = nullptr; return E_NOTIMPL; }

    IFACEMETHODIMP SetSite(_In_ IUnknown* site) noexcept { m_site = site; return S_OK; }
    IFACEMETHODIMP GetSite(_In_ REFIID riid, _COM_Outptr_ void** site) noexcept { return m_site.CopyTo(riid, site); }

protected:
    ComPtr<IUnknown> m_site;
};

//               ᐯ If you change the class name you need to change this line too.
CoCreatableClass(YourAppMenuCommand)
//                                   ᐯ And this
CoCreatableClassWrlCreatorMapInclude(YourAppMenuCommand)

STDAPI DllGetActivationFactory(_In_ HSTRING activatableClassId, _COM_Outptr_ IActivationFactory** factory)
{
    return Module<ModuleType::InProc>::GetModule().GetActivationFactory(activatableClassId, factory);
}

STDAPI DllCanUnloadNow()
{
    return Module<InProc>::GetModule().GetObjectCount() == 0 ? S_OK : S_FALSE;
}

STDAPI DllGetClassObject(_In_ REFCLSID rclsid, _In_ REFIID riid, _Outptr_ LPVOID FAR* ppv)
{
    return Module<InProc>::GetModule().GetClassObject(rclsid, riid, ppv);
}