//
//  SiteSettingsView.swift
//  Unagent
//
//  Created by シンジャスティン on 2023/05/28.
//

import SwiftUI

struct SiteSettingsView: View {
    
    let defaults: UserDefaults = UserDefaults(suiteName: "group.\(Bundle.main.bundleIdentifier!)")!
    
    @State var siteSettings: [SiteSetting] = []
    @State var willSaveSiteSettingsToMemory: Bool = false
    @State var isShowingNewSiteSettingView: Bool = false
    
    @State var newSiteSettingDomain: String = ""
    @State var newSiteSettingUserAgent: String = ""
    @State var newSiteSettingWillBeCreated: Bool = false
    
    var body: some View {
        NavigationStack {
            Group {
                if siteSettings.isEmpty {
                    if #available(iOS 17.0, *) {
                        ContentUnavailableView("SiteSettings.EmptyText.Title", systemImage: "plus.square.on.square", description: Text("SiteSettings.EmptyText.Text"))
                    }
                } else {
                    List(siteSettings, id: \.domain) { siteSetting in
                        SiteSettingRow(title: siteSetting.domain,
                                       subtitle: siteSetting.userAgent)
                        .swipeActions {
                            Button("Shared.Delete") {
                                siteSettings.removeAll(where: {$0.domain == siteSetting.domain})
                                saveToMemory()
                            }
                            .tint(.red)
                        }
                    }
                }
            }
            .navigationTitle("ViewTitle.SiteSettings")
            .sheet(isPresented: $isShowingNewSiteSettingView, content: {
                SiteSettingsNewView(domain: $newSiteSettingDomain,
                                    userAgent: $newSiteSettingUserAgent,
                                    willCreateSiteSetting: $newSiteSettingWillBeCreated)
                .presentationDetents([.large, .medium])
            })
            .onAppear {
                let decoder = JSONDecoder()
                if defaults.string(forKey: "SiteSettings") != nil {
                    if let jsonString = defaults.string(forKey: "SiteSettings"),
                       let jsonData = jsonString.data(using: .utf8),
                       let siteSettings = try? decoder.decode([SiteSetting].self, from: jsonData) {
                        self.siteSettings = siteSettings
                    }
                } else {
                    defaults.set([] as [SiteSetting], forKey: "SiteSettings")
                }
                willSaveSiteSettingsToMemory = true
            }
            .onChange(of: isShowingNewSiteSettingView, perform: { newValue in
                if !newValue && newSiteSettingWillBeCreated {
                    siteSettings.append(SiteSetting(domain: newSiteSettingDomain,
                                                    userAgent: newSiteSettingUserAgent))
                    newSiteSettingDomain = ""
                    newSiteSettingUserAgent = ""
                    newSiteSettingWillBeCreated = false
                    saveToMemory()
                }
            })
            .scrollDismissesKeyboard(.immediately)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        isShowingNewSiteSettingView = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
        }
    }
    
    func saveToMemory() {
        let encoder = JSONEncoder()
        if let jsonData = try? encoder.encode(siteSettings),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            defaults.set(jsonString, forKey: "SiteSettings")
        }
    }
}
